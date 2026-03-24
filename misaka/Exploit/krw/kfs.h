#ifndef kfs_h
#define kfs_h

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <sys/types.h>

typedef void (*kfs_log_callback_t)(const char *message);
void kfs_set_log_callback(kfs_log_callback_t cb);

typedef struct {
    char name[256];
    uint8_t d_type;   /* DT_DIR=4, DT_REG=8, DT_LNK=10, etc. */
} kfs_entry_t;

/// Initialize kernel filesystem access.  Call after exploit_run() succeeds.
int  kfs_init(void);
bool kfs_is_ready(void);

/// List directory via kernel name cache.  Caller must free with kfs_free_listing().
int  kfs_listdir(const char *path, kfs_entry_t **out, int *count);
void kfs_free_listing(kfs_entry_t *entries);

/// Read file data via UBC pages.  Returns bytes read, -1 on error.
int64_t kfs_read(const char *path, void *buf, size_t size, off_t offset);

/// Write file data via UBC pages.  Returns bytes written, -1 on error.
int64_t kfs_write(const char *path, const void *buf, size_t size, off_t offset);

/// Get file size from UBC info.  Returns -1 on error.
int64_t kfs_file_size(const char *path);

/// Overwrite a system file with a local file using vm_map entry protection patching.
/// No vnode offsets needed — uses proc→task→vm_map→entry→flags.
/// `to` = target system file path (e.g. /System/Library/Fonts/CoreUI/SFUI.ttf)
/// `from` = replacement file path in sandbox (e.g. app bundle path)
/// Returns 0 on success.
int kfs_overwrite_file(const char *to, const char *from);

/// Overwrite a system file with raw bytes at a given offset.
int kfs_overwrite_file_bytes(const char *path, off_t offset, const void *data, size_t len);

#endif /* kfs_h */
