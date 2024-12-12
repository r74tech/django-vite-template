from django.conf import settings

def is_debug(request):
    return {"DEBUG": settings.DEBUG}
