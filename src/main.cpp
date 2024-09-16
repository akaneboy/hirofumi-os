#include <cstdint>
#include <cstddef>
#include <cstring>
#include <limine.h>

[[gnu::used, gnu::section(".requests")]]
static volatile LIMINE_BASE_REVISION(2);

[[gnu::used, gnu::section(".requests")]]
static volatile struct limine_framebuffer_request framebuffer_request = {
    .id = LIMINE_FRAMEBUFFER_REQUEST,
    .revision = 0,
    .response = nullptr
};

[[gnu::used, gnu::section(".requests_start_marker")]]
static volatile LIMINE_REQUESTS_START_MARKER;

[[gnu::used, gnu::section(".requests_end_marker")]]
static volatile LIMINE_REQUESTS_END_MARKER;

static void hcf() {
    for (;;) {
        asm ("hlt");
    }
}

extern "C" void kmain() {
    if (LIMINE_BASE_REVISION_SUPPORTED == false) {
        hcf();
    }

    if (framebuffer_request.response == nullptr
     || framebuffer_request.response->framebuffer_count < 1) {
        hcf();
    }

    struct limine_framebuffer *framebuffer = framebuffer_request.response->framebuffers[0];

    for (size_t i = 0; i < 100; i++) {
        volatile uint32_t *fb_ptr = static_cast<volatile uint32_t*>(framebuffer->address);
        fb_ptr[i * (framebuffer->pitch / 4) + i] = 0xffffff;
    }

    hcf();
}
