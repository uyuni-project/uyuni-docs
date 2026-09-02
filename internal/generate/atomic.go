package generate

// Atomic file writes.
//
// build_pdfs.sh runs one 'task pdf' process for each book, and books of one
// language read the same generated files. A developer can also run 'task gen'
// in a second terminal during a build. A write to a temporary file, then a
// rename, keeps each write atomic for other processes: a reader gets the
// previous complete file or the new complete file, never a truncated one.
//
// This function does not fsync. Every file it writes is a build artifact that
// the build makes again.

import (
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
)

// atomicWriteFile writes data to path through a temporary file and a rename.
// The temporary file is in the destination directory. The rename therefore
// stays in one filesystem.
func atomicWriteFile(path string, data []byte, perm os.FileMode) error {
	dir := filepath.Dir(path)
	base := filepath.Base(path)

	// os.CreateTemp is not usable here. It creates the file 0600 and needs a
	// subsequent chmod to perm, and chmod ignores the umask. O_CREATE|O_EXCL
	// with perm applies the umask, like os.WriteFile.
	var (
		tmp     *os.File
		tmpName string
		err     error
	)
	// The name holds the process ID, so two processes never pick the same one.
	// The index handles a leftover temporary file from a process that was
	// killed before its cleanup ran and whose process ID has been reused.
	const maxAttempts = 100
	for i := 0; tmp == nil && i < maxAttempts; i++ {
		tmpName = filepath.Join(dir, fmt.Sprintf(".%s.tmp%d-%d", base, os.Getpid(), i))
		tmp, err = os.OpenFile(tmpName, os.O_WRONLY|os.O_CREATE|os.O_EXCL, perm)
		if err != nil && !errors.Is(err, fs.ErrExist) {
			return fmt.Errorf("create temp file for %s: %w", path, err)
		}
	}
	if tmp == nil {
		return fmt.Errorf("create temp file for %s: every name from .%s.tmp%d-0 to -%d is taken, "+
			"remove the stale .%s.tmp* files in %s: %w",
			path, base, os.Getpid(), maxAttempts-1, base, dir, err)
	}

	// An empty tmpName disables this cleanup after a successful rename.
	defer func() {
		if tmpName != "" {
			tmp.Close()
			// Report a leftover temporary file. Enough of them make every
			// later write to this path fail with the message above.
			if err := os.Remove(tmpName); err != nil {
				fmt.Fprintf(os.Stderr, "warning: cannot remove temp file %s: %v\n", tmpName, err)
			}
		}
	}()

	if _, err := tmp.Write(data); err != nil {
		return fmt.Errorf("write %s: %w", tmpName, err)
	}
	if err := tmp.Close(); err != nil {
		return fmt.Errorf("close %s: %w", tmpName, err)
	}
	if err := os.Rename(tmpName, path); err != nil {
		return fmt.Errorf("rename %s -> %s: %w", tmpName, path, err)
	}
	tmpName = ""
	return nil
}
