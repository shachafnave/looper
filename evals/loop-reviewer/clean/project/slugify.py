import re


def slugify(text):
    dashed = re.sub(r"[^A-Za-z0-9]+", "-", text).lower()
    return dashed.strip("-")
