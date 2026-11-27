def paginate(items, page, per_page):
    start = page * per_page
    end = start + per_page - 1
    return items[start:end]


def page_count(total, per_page):
    return (total + per_page - 1) // per_page
