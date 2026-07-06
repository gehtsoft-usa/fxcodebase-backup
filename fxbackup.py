#!/usr/bin/env python3
"""fxbackup.py - Back up an fxcodebase.com phpBB forum to Markdown + attachments.

Usage:
    python3 fxbackup.py <forum-url> <output-folder> [options]

Example:
    python3 fxbackup.py "https://fxcodebase.com/code/viewforum.php?f=17" ./backup

For each forum it creates:

    <output>/f<ID>-<forum-slug>/
        forum.md                      index of all topics
        t<ID>-<topic-slug>/
            index.md                  the whole thread as Markdown
            files/  <id>-name.lua     downloaded indicators / attachments
            images/ <id>-name.png     downloaded screenshots

One folder per topic (thread); all messages of the thread go into one index.md,
with images and file attachments downloaded locally and referenced from it.

The site sits behind Cloudflare; this script assumes the running host's IP is
allow-listed at Cloudflare (plain HTTP works). No FlareSolverr / cookies needed.
Standard library only.
"""

import argparse
import html
import os
import re
import sys
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from html.parser import HTMLParser

UA = ("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36")

# --------------------------------------------------------------------------- #
#  HTTP                                                                         #
# --------------------------------------------------------------------------- #

class Http:
    def __init__(self, delay=0.4, retries=4, timeout=60, verbose=False):
        self.delay = delay
        self.retries = retries
        self.timeout = timeout
        self.verbose = verbose
        self._next = 0.0
        self._lock = threading.Lock()

    def _throttle(self):
        """Global rate limiter: hands each caller a start slot spaced `delay`
        apart, without holding the lock while sleeping, so concurrent workers
        overlap their network waits but the aggregate request rate stays
        bounded to ~1/delay per second."""
        with self._lock:
            now = time.time()
            slot = self._next if self._next > now else now
            self._next = slot + self.delay
        wait = slot - time.time()
        if wait > 0:
            time.sleep(wait)

    def get(self, url):
        """Return (bytes, headers). Retries transient errors with backoff."""
        last_err = None
        for attempt in range(self.retries):
            self._throttle()
            try:
                req = urllib.request.Request(url, headers={
                    "User-Agent": UA,
                    "Accept": "text/html,application/xhtml+xml,image/*,*/*",
                    "Accept-Language": "en-US,en;q=0.9",
                })
                with urllib.request.urlopen(req, timeout=self.timeout) as resp:
                    return resp.read(), resp.headers
            except urllib.error.HTTPError as e:
                last_err = e
                if e.code in (429, 500, 502, 503, 504):
                    time.sleep(2 * (attempt + 1))
                    continue
                raise
            except (urllib.error.URLError, TimeoutError, ConnectionError) as e:
                last_err = e
                time.sleep(2 * (attempt + 1))
        raise last_err

    def get_html(self, url):
        data, _ = self.get(url)
        return data.decode("utf-8", "replace")


# --------------------------------------------------------------------------- #
#  Small helpers                                                                #
# --------------------------------------------------------------------------- #

_TAG_RE = re.compile(r"<[^>]+>")
_WS_RE = re.compile(r"\s+")


def strip_html(fragment):
    """Tags out, entities decoded, whitespace collapsed."""
    if not fragment:
        return ""
    text = _TAG_RE.sub(" ", fragment)
    text = html.unescape(text)
    return _WS_RE.sub(" ", text).strip()


def slugify(text, maxlen=60):
    text = html.unescape(text or "").lower()
    text = re.sub(r"[^a-z0-9]+", "-", text).strip("-")
    if len(text) > maxlen:
        text = text[:maxlen].rstrip("-")
    return text or "untitled"


def bucket_of(name):
    """First-character bucket for a topic folder, keeping any single forum
    directory well under GitHub's ~1000-entries-per-folder comfort zone:
    'a'-'z' by first letter, digits into '0-9', anything else into '_'."""
    c = name[:1].lower()
    if "a" <= c <= "z":
        return c
    if c.isdigit():
        return "0-9"
    return "_"


def assign_topic_folders(topics):
    """Map topic-id -> folder name. Clean slug when unique; on collision the
    lowest topic-id keeps the clean slug and the rest get a '-t<id>' suffix.
    Deterministic (tiebreak by numeric id), so it is independent of forum
    listing order and stable across resumes."""
    names = {}
    used = {}
    for tid, title, _ in sorted(topics, key=lambda t: int(t[0])):
        base = slugify(title)
        name = base if base not in used else f"{base}-t{tid}"
        while name in used:                         # extremely unlikely
            name = f"{name}-{tid}"
        used[name] = tid
        names[tid] = name
    return names


_SAFE_NAME_RE = re.compile(r'[^A-Za-z0-9._ \-()]+')


def sanitize_filename(name, fallback="file"):
    name = html.unescape(name or "").strip().replace("/", "-").replace("\\", "-")
    name = _SAFE_NAME_RE.sub("", name).strip()
    name = re.sub(r"\s+", " ", name)
    return name or fallback


def resolve_url(base, href):
    href = html.unescape(href).strip()
    return urllib.parse.urljoin(base, href)


def strip_sid(url):
    """Remove the volatile phpBB session id from a URL/query."""
    parts = urllib.parse.urlsplit(url)
    q = [(k, v) for k, v in urllib.parse.parse_qsl(parts.query, keep_blank_values=True)
         if k != "sid"]
    return urllib.parse.urlunsplit(parts._replace(query=urllib.parse.urlencode(q)))


def parse_filename_from_disposition(headers, fallback):
    """Extract a clean filename. The server percent-encodes it (and UA-sniffs
    between the RFC5987 `filename*=` and legacy `filename=` forms), so every
    branch percent-decodes before sanitizing."""
    cd = headers.get("Content-Disposition", "") if headers else ""
    m = re.search(r"filename\*\s*=\s*[^']*''([^;]+)", cd)
    if m:
        return sanitize_filename(urllib.parse.unquote(m.group(1)), fallback)
    m = re.search(r'filename\s*=\s*"([^"]+)"', cd)
    if m:
        return sanitize_filename(urllib.parse.unquote(m.group(1)), fallback)
    m = re.search(r"filename\s*=\s*([^;]+)", cd)
    if m:
        return sanitize_filename(urllib.parse.unquote(m.group(1).strip()), fallback)
    return sanitize_filename(fallback)


# --------------------------------------------------------------------------- #
#  HTML -> Markdown converter (for phpBB post content)                          #
# --------------------------------------------------------------------------- #

_PUSH_TAGS = {"b", "strong", "i", "em", "u", "span", "a", "code", "pre",
              "blockquote", "cite", "li", "h1", "h2", "h3", "h4", "h5", "h6"}
_SKIP_TAGS = {"script", "style"}


class MarkdownConverter(HTMLParser):
    """Converts the limited HTML phpBB emits inside <div class="content">.

    Attachment blocks (dl.thumbnail / dl.file) must already have been replaced
    by \\x00ATT<n>\\x00 placeholder tokens before feeding HTML here; the tokens
    pass through untouched as plain text and are substituted later.
    """

    def __init__(self, base_url):
        super().__init__(convert_charrefs=True)
        self.base_url = base_url
        self.stack = [{"tag": "_root", "buf": [], "meta": {}}]
        self.list_stack = []      # entries: [type, counter]
        self.skip_depth = 0

    # -- buffer helpers -------------------------------------------------------
    def emit(self, s):
        self.stack[-1]["buf"].append(s)

    def _push(self, tag, meta=None):
        self.stack.append({"tag": tag, "buf": [], "meta": meta or {}})

    def _pop_fold(self, tag):
        # pop nearest matching entry; ignore stray closers
        for i in range(len(self.stack) - 1, 0, -1):
            if self.stack[i]["tag"] == tag:
                entry = self.stack.pop(i)
                # any accidental entries above get flushed inline
                folded = self._fold(entry)
                self.emit(folded)
                return

    def _fold(self, entry):
        tag = entry["tag"]
        inner = "".join(entry["buf"])
        meta = entry["meta"]
        s = inner.strip()
        if tag in ("b", "strong"):
            return f"**{s}**" if s else ""
        if tag in ("i", "em"):
            return f"_{s}_" if s else ""
        if tag == "u":
            return inner
        if tag == "span":
            return f"**{s}**" if (meta.get("bold") and s) else inner
        if tag == "a":
            href = meta.get("href")
            if href and not href.startswith("#") and s:
                return f"[{s}]({href})"
            return inner
        if tag == "code":
            return f"`{s}`" if s else ""
        if tag == "pre":
            body = inner.strip("\n")
            return f"\n\n```\n{body}\n```\n\n"
        if tag == "cite":
            return f"**{s}**\n" if s else ""
        if tag == "blockquote":
            body = inner.strip("\n")
            lines = body.split("\n")
            quoted = "\n".join(("> " + ln) if ln.strip() else ">" for ln in lines)
            return f"\n\n{quoted}\n\n"
        if tag == "li":
            depth = max(0, len(self.list_stack) - 1)
            indent = "  " * depth
            if self.list_stack and self.list_stack[-1][0] == "ol":
                self.list_stack[-1][1] += 1
                marker = f"{self.list_stack[-1][1]}. "
            else:
                marker = "- "
            return f"\n{indent}{marker}{s}"
        if tag in ("h1", "h2", "h3", "h4", "h5", "h6"):
            level = int(tag[1])
            return f"\n\n{'#' * min(level + 2, 6)} {s}\n\n" if s else ""
        return inner

    # -- parser callbacks -----------------------------------------------------
    def handle_starttag(self, tag, attrs):
        if tag in _SKIP_TAGS:
            self.skip_depth += 1
            return
        if self.skip_depth:
            return
        a = dict(attrs)
        if tag == "br":
            self.emit("\n")
        elif tag in ("p", "div"):
            self.emit("\n\n")
        elif tag in ("ul", "ol"):
            self.list_stack.append([tag, 0])
            self.emit("\n")
        elif tag in ("dl", "dt", "dd", "tr"):
            self.emit("\n")
        elif tag == "img":
            pass  # attachments are pre-extracted; ignore decorative imgs
        elif tag in _PUSH_TAGS:
            meta = {}
            if tag == "a" and a.get("href"):
                meta["href"] = resolve_url(self.base_url, a["href"])
            if tag == "span":
                style = (a.get("style") or "").lower()
                meta["bold"] = "bold" in style or "700" in style
            self._push(tag, meta)

    def handle_endtag(self, tag):
        if tag in _SKIP_TAGS:
            self.skip_depth = max(0, self.skip_depth - 1)
            return
        if self.skip_depth:
            return
        if tag in ("ul", "ol"):
            if self.list_stack:
                self.list_stack.pop()
            self.emit("\n")
        elif tag in ("p", "div"):
            self.emit("\n\n")
        elif tag in _PUSH_TAGS:
            self._pop_fold(tag)

    def handle_data(self, data):
        if self.skip_depth:
            return
        self.emit(data)

    def get_markdown(self):
        # flush any unclosed pushed entries
        while len(self.stack) > 1:
            entry = self.stack.pop()
            self.stack[-1]["buf"].append(self._fold(entry))
        text = "".join(self.stack[0]["buf"])
        text = text.replace("\r", "")
        text = re.sub(r"[ \t]+\n", "\n", text)          # trailing spaces
        text = re.sub(r"\n{3,}", "\n\n", text)          # collapse blank runs
        text = re.sub(r"[ \t]{2,}", " ", text)
        return text.strip()


def html_to_markdown(content_html, base_url):
    conv = MarkdownConverter(base_url)
    conv.feed(content_html)
    conv.close()
    return conv.get_markdown()


# --------------------------------------------------------------------------- #
#  Attachment extraction                                                        #
# --------------------------------------------------------------------------- #

_THUMB_RE = re.compile(r'<dl class="thumbnail">.*?</dl>', re.S)
_FILE_RE = re.compile(r'<dl class="file">.*?</dl>', re.S)
_ID_RE = re.compile(r"file\.php\?id=(\d+)")


def extract_attachments(content_html):
    """Replace attachment DL blocks with placeholder tokens.

    Returns (html_with_tokens, occ_list). occ_list entries:
        {kind: 'image'|'file', id: str, name: str, caption: str}
    """
    occ = []

    def repl_thumb(m):
        block = m.group(0)
        idm = _ID_RE.search(block)
        fid = idm.group(1) if idm else None
        altm = re.search(r'<img[^>]*\balt="([^"]*)"', block)
        name = html.unescape(altm.group(1)) if altm and altm.group(1) else (fid or "image")
        ddm = re.search(r"<dd>(.*?)</dd>", block, re.S)
        caption = strip_html(ddm.group(1)) if ddm else ""
        occ.append({"kind": "image", "id": fid, "name": name, "caption": caption})
        return f"\x00ATT{len(occ) - 1}\x00"

    def repl_file(m):
        block = m.group(0)
        idm = _ID_RE.search(block)
        fid = idm.group(1) if idm else None
        am = re.search(r"<a[^>]*>(.*?)</a>", block, re.S)
        name = strip_html(am.group(1)) if am else (fid or "file")
        occ.append({"kind": "file", "id": fid, "name": name, "caption": ""})
        return f"\x00ATT{len(occ) - 1}\x00"

    html_out = _THUMB_RE.sub(repl_thumb, content_html)
    html_out = _FILE_RE.sub(repl_file, html_out)
    return html_out, occ


# --------------------------------------------------------------------------- #
#  Page parsing                                                                 #
# --------------------------------------------------------------------------- #

_CONTENT_OPEN_RE = re.compile(r'<div class="content">')
_DIV_TOKEN_RE = re.compile(r"<div\b[^>]*>|</div>")


def extract_content_html(post_frag):
    """Inner HTML of <div class="content"> via depth matching."""
    m = _CONTENT_OPEN_RE.search(post_frag)
    if not m:
        return ""
    start = m.end()
    depth = 1
    for tok in _DIV_TOKEN_RE.finditer(post_frag, start):
        if tok.group().startswith("</div"):
            depth -= 1
            if depth == 0:
                return post_frag[start:tok.start()]
        else:
            depth += 1
    return post_frag[start:]


_POST_SPLIT_RE = re.compile(r'(?=<div id="p\d+" class="post bg[12]")')
_POST_START_RE = re.compile(r'<div id="p(\d+)" class="post bg[12]"')
_AUTHOR_RE = re.compile(r'<p class="author">(.*?)</p>', re.S)
_SUBJECT_RE = re.compile(r"<h3[^>]*>\s*<a[^>]*>(.*?)</a>", re.S)
_PROFILE_RE = re.compile(r"viewprofile[^>]*>(.*?)</a>", re.S)


def parse_author(frag):
    m = _AUTHOR_RE.search(frag)
    if not m:
        return (None, None)
    seg = m.group(1)
    text = strip_html(seg)
    pm = _PROFILE_RE.search(seg)
    name = strip_html(pm.group(1)) if pm else None
    if not name:
        bm = re.search(r"by\s+(.*?)\s+[»»]", text)
        name = bm.group(1) if bm else None
    dm = re.search(r"[»»]\s*(.+)$", text)
    date = dm.group(1).strip() if dm else None
    return (name, date)


def parse_posts(page_html):
    frags = [f for f in _POST_SPLIT_RE.split(page_html)
             if _POST_START_RE.match(f)]
    posts = []
    for frag in frags:
        pm = _POST_START_RE.match(frag)
        post_id = pm.group(1) if pm else None
        author, date = parse_author(frag)
        sm = _SUBJECT_RE.search(frag)
        subject = strip_html(sm.group(1)) if sm else None
        content_html = extract_content_html(frag)
        content_html, occ = extract_attachments(content_html)
        posts.append({
            "post_id": post_id,
            "author": author,
            "date": date,
            "subject": subject,
            "content_html": content_html,
            "occ": occ,
        })
    return posts


def parse_forum_meta(page_html):
    """Return (forum_title, total_topics, topics_per_page)."""
    tm = re.search(r'<h2><a href="[^"]*viewforum[^"]*">(.*?)</a></h2>', page_html)
    if not tm:
        tm = re.search(r"View forum - ([^<]+)</title>", page_html)
    title = strip_html(tm.group(1)) if tm else "forum"
    cm = re.search(r"(\d+)\s+topics", page_html)
    total = int(cm.group(1)) if cm else None
    starts = sorted({int(x) for x in re.findall(
        r"viewforum\.php\?[^\"']*start=(\d+)", page_html)})
    per_page = starts[0] if starts else 25
    return title, total, per_page


_TOPIC_ROW_RE = re.compile(
    r'<a href="\./(viewtopic\.php\?[^"]*?t=(\d+)[^"]*)" class="topictitle">(.*?)</a>',
    re.S)


def parse_topic_rows(page_html):
    """Return list of (topic_id, title, href) preserving order, deduped by id."""
    rows = []
    seen = set()
    for m in _TOPIC_ROW_RE.finditer(page_html):
        tid = m.group(2)
        if tid in seen:
            continue
        seen.add(tid)
        rows.append((tid, strip_html(m.group(3)), m.group(1)))
    return rows


def parse_topic_meta(page_html):
    """Return (topic_title, num_pages, posts_per_page)."""
    tm = re.search(r'<h2><a href="[^"]*viewtopic[^"]*">(.*?)</a></h2>', page_html)
    if not tm:
        tm = re.search(r"View topic - ([^<]+)</title>", page_html)
    title = strip_html(tm.group(1)) if tm else "topic"
    ppm = re.search(r"var per_page = '(\d+)'", page_html)
    per_page = int(ppm.group(1)) if ppm else 10
    pm = re.search(r"Page <strong>\d+</strong> of <strong>(\d+)</strong>", page_html)
    pages = int(pm.group(1)) if pm else 1
    return title, pages, per_page


# --------------------------------------------------------------------------- #
#  Backup driver                                                                #
# --------------------------------------------------------------------------- #

class Backup:
    def __init__(self, forum_url, out_dir, http, force=False, limit=None,
                 verbose=False, workers=1):
        self.forum_url = forum_url
        self.out_dir = out_dir
        self.http = http
        self.force = force
        self.limit = limit
        self.verbose = verbose
        self.workers = max(1, workers)
        self._stats_lock = threading.Lock()
        self._log_lock = threading.Lock()
        parts = urllib.parse.urlsplit(forum_url)
        # base = https://host/code/
        self.base = urllib.parse.urlunsplit(
            parts._replace(path=parts.path.rsplit("/", 1)[0] + "/", query="",
                           fragment=""))
        q = dict(urllib.parse.parse_qsl(parts.query))
        self.forum_id = q.get("f", "0")
        self.stats = {"topics": 0, "posts": 0, "files": 0, "images": 0,
                      "skipped": 0, "failed": 0}

    def log(self, msg):
        with self._log_lock:
            print(msg, flush=True)

    def bump(self, key, n=1):
        with self._stats_lock:
            self.stats[key] += n

    # -- crawl ----------------------------------------------------------------
    def collect_topics(self):
        topics = []
        seen = set()
        start = 0
        forum_title = None
        total = None
        per_page = 25
        while True:
            url = f"{self.base}viewforum.php?f={self.forum_id}&start={start}"
            page = self.http.get_html(url)
            if forum_title is None:
                forum_title, total, per_page = parse_forum_meta(page)
                self.log(f"Forum: {forum_title} (f={self.forum_id}) "
                         f"- {total if total is not None else '?'} topics, "
                         f"{per_page}/page")
            rows = parse_topic_rows(page)
            new = 0
            for tid, title, href in rows:
                if tid in seen:
                    continue
                seen.add(tid)
                topics.append((tid, title, href))
                new += 1
            start += per_page
            if new == 0:
                break
            if total is not None and start >= total:
                break
            if self.limit and len(topics) >= self.limit:
                break
        return forum_title, topics

    def crawl_topic(self, tid, href):
        topic_url = resolve_url(self.base, href)
        first = self.http.get_html(topic_url)
        title, pages, per_page = parse_topic_meta(first)
        posts = parse_posts(first)
        for p in range(1, pages):
            url = (f"{self.base}viewtopic.php?f={self.forum_id}"
                   f"&t={tid}&start={p * per_page}")
            posts += parse_posts(self.http.get_html(url))
        return title, strip_sid(topic_url), posts

    # -- attachments ----------------------------------------------------------
    def download_attachment(self, topic_dir, post_id, occ, assigned):
        """Save one attachment under <subdir>/<post-id>/<clean-name>.

        Filenames are kept clean; attachments are grouped per post via the
        post-id subfolder. Different versions posted in different replies land
        in different post folders. If two different attachments in the SAME
        post share a name, the later one gets a ' (2)' suffix so no version is
        overwritten. `assigned` maps absolute-path -> attachment id for the
        current topic so collisions are detected deterministically.
        """
        fid = occ["id"]
        if not fid:
            return None
        if occ["kind"] == "image":
            url = f"{self.base}download/file.php?id={fid}&mode=view"
            subdir = "images"
        else:
            url = f"{self.base}download/file.php?id={fid}"
            subdir = "files"
        try:
            data, headers = self.http.get(url)
        except Exception as e:                                  # noqa: BLE001
            self.log(f"    ! failed to download id={fid}: {e}")
            self.bump("failed")
            return None
        hint = occ.get("name") or fid
        fname = parse_filename_from_disposition(headers, hint)
        if "." not in fname:
            ctype = (headers.get("Content-Type", "") if headers else "").split(";")[0]
            ext = {"image/png": ".png", "image/jpeg": ".jpg", "image/gif": ".gif",
                   "text/plain": ".txt", "application/zip": ".zip"}.get(ctype, "")
            fname += ext

        pfolder = post_id or "0"
        d = os.path.join(topic_dir, subdir, pfolder)
        os.makedirs(d, exist_ok=True)
        stem, ext = os.path.splitext(fname)
        candidate = fname
        n = 2
        while True:
            path = os.path.join(d, candidate)
            owner = assigned.get(path)
            if owner is None or owner == fid:
                break                                   # free, or already ours
            candidate = f"{stem} ({n}){ext}"            # same-name, other file
            n += 1
        assigned[path] = fid
        if not (os.path.exists(path) and not self.force):
            with open(path, "wb") as fh:
                fh.write(data)
        self.bump("images" if subdir == "images" else "files")
        return f"{subdir}/{pfolder}/{candidate}"

    # -- rendering ------------------------------------------------------------
    def render_topic(self, topic_dir, tid, title, topic_url, posts):
        # download unique attachments (grouped per post-id subfolder)
        idmap = {}
        assigned = {}
        for post in posts:
            for occ in post["occ"]:
                key = (occ["id"], occ["kind"])
                if occ["id"] and key not in idmap:
                    idmap[key] = self.download_attachment(
                        topic_dir, post["post_id"], occ, assigned)

        lines = [f"# {title}\n",
                 f"> Source: {topic_url}  ",
                 f"> Forum: {self.forum_id} · Topic {tid} · "
                 f"{len(posts)} post(s)\n"]

        for idx, post in enumerate(posts):
            md = html_to_markdown(post["content_html"], self.base)
            md = self._substitute(md, post["occ"], idmap)
            subject = post["subject"] or f"Post {idx + 1}"
            meta = []
            if post["author"]:
                meta.append(f"**{post['author']}**")
            if post["date"]:
                meta.append(post["date"])
            lines.append("\n---\n")
            lines.append(f"## {subject}\n")
            if meta:
                lines.append(" · ".join(meta) + "\n")
            lines.append(md.strip() + "\n")

        os.makedirs(topic_dir, exist_ok=True)
        with open(os.path.join(topic_dir, "index.md"), "w", encoding="utf-8") as fh:
            fh.write("\n".join(lines).rstrip() + "\n")

    @staticmethod
    def _substitute(md, occ_list, idmap):
        seen = set()

        def repl(m):
            occ = occ_list[int(m.group(1))]
            key = (occ["id"], occ["kind"])
            if key in seen:
                return ""                      # drop repeat (bottom attachbox)
            seen.add(key)
            path = idmap.get(key)
            link = urllib.parse.quote(path, safe="/") if path else None
            name = occ["name"].replace("]", ")").replace("[", "(")
            if occ["kind"] == "image":
                if link:
                    ref = f"![{name}]({link})"
                else:
                    ref = f"*(image id {occ['id']} - download failed)*"
                if occ.get("caption"):
                    ref += f"\n\n*{occ['caption']}*"
                return "\n\n" + ref + "\n\n"
            if link:
                return f"[{name}]({link})"
            return f"[{name}](download/file.php?id={occ['id']} - download failed)"

        return re.sub(r"\x00ATT(\d+)\x00", repl, md)

    # -- run ------------------------------------------------------------------
    def resolve_forum_dir(self, forum_title):
        """Clean forum-folder name; append '-f<id>' only if a folder of that
        name already belongs to a different forum (tracked via .forum-id)."""
        slug = slugify(forum_title)
        forum_dir = os.path.join(self.out_dir, slug)
        marker = os.path.join(forum_dir, ".forum-id")
        if os.path.isdir(forum_dir):
            existing = None
            if os.path.exists(marker):
                with open(marker, encoding="utf-8") as fh:
                    existing = fh.read().strip()
            if existing not in (None, self.forum_id):
                forum_dir = os.path.join(self.out_dir, f"{slug}-f{self.forum_id}")
        os.makedirs(forum_dir, exist_ok=True)
        with open(os.path.join(forum_dir, ".forum-id"), "w", encoding="utf-8") as fh:
            fh.write(self.forum_id)
        return forum_dir

    def run(self):
        forum_title, topics = self.collect_topics()
        forum_dir = self.resolve_forum_dir(forum_title)
        self.log(f"Collected {len(topics)} topics.")

        if self.limit:
            topics = topics[:self.limit]

        names = assign_topic_folders(topics)

        # forum.md index is built from topic order (independent of the order
        # topics finish processing under concurrency).
        index_lines = [f"# {forum_title} (f{self.forum_id})\n",
                       f"> Source: {strip_sid(self.forum_url)}  ",
                       f"> Topics: {len(topics)}\n"]
        for tid, title, _ in topics:
            name = names[tid]
            index_lines.append(f"- [{title}]({bucket_of(name)}/{name}/index.md)")
        with open(os.path.join(forum_dir, "forum.md"), "w", encoding="utf-8") as fh:
            fh.write("\n".join(index_lines).rstrip() + "\n")

        total = len(topics)
        counter = [0]
        counter_lock = threading.Lock()

        def handle(item):
            tid, title, href = item
            name = names[tid]
            topic_dir = os.path.join(forum_dir, bucket_of(name), name)
            with counter_lock:
                counter[0] += 1
                n = counter[0]
            index_path = os.path.join(topic_dir, "index.md")
            if os.path.exists(index_path) and not self.force:
                self.bump("skipped")
                self.log(f"[{n}/{total}] t={tid} skip (exists): {title}")
                return
            try:
                real_title, topic_url, posts = self.crawl_topic(tid, href)
                self.render_topic(topic_dir, tid, real_title or title,
                                  topic_url, posts)
                self.bump("topics")
                self.bump("posts", len(posts))
                self.log(f"[{n}/{total}] t={tid} "
                         f"({len(posts)} posts): {real_title or title}")
            except Exception as e:                              # noqa: BLE001
                self.bump("failed")
                self.log(f"[{n}/{total}] t={tid} ERROR: {e}")

        if self.workers > 1:
            with ThreadPoolExecutor(max_workers=self.workers) as ex:
                for fut in as_completed(ex.submit(handle, it) for it in topics):
                    fut.result()
        else:
            for it in topics:
                handle(it)

        self.log("Done. " + ", ".join(f"{k}={v}" for k, v in self.stats.items()))
        self.log(f"Output: {forum_dir}")


# --------------------------------------------------------------------------- #

def main(argv=None):
    ap = argparse.ArgumentParser(description="Back up an fxcodebase.com forum "
                                             "to Markdown + attachments.")
    ap.add_argument("forum_url", help="e.g. https://fxcodebase.com/code/viewforum.php?f=17")
    ap.add_argument("out_dir", help="output folder")
    ap.add_argument("--delay", type=float, default=0.4,
                    help="min seconds between HTTP request starts, global "
                         "(default 0.4)")
    ap.add_argument("--workers", type=int, default=1,
                    help="number of topics to process in parallel (default 1)")
    ap.add_argument("--limit", type=int, default=None,
                    help="process at most N topics (for testing)")
    ap.add_argument("--force", action="store_true",
                    help="re-download topics/attachments even if present")
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args(argv)

    http = Http(delay=args.delay, verbose=args.verbose)
    Backup(args.forum_url, args.out_dir, http, force=args.force,
           limit=args.limit, verbose=args.verbose, workers=args.workers).run()


if __name__ == "__main__":
    sys.exit(main())
