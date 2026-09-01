package generate

// Atomic file writes.
//
// The PDF matrix builds books in parallel, and more than one book of a
// language writes the same shared files, primarily entities.adoc. A write to a
// temporary file, then a rename, keeps each write atomic for other processes:
// a reader gets the previous complete file or the new complete file. These
// functions do not fsync, because 'task gen' makes all these files again.

import (
	"fmt"
	"os"
	"path/filepath"
)

// atomicWriteFile writes data to path through a temporary file and a rename.
// The temporary file is in the destination directory, therefore the rename
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
	for i := 0; tmp == nil && i < 100; i++ {
		tmpName = filepath.Join(dir, fmt.Sprintf(".%s.tmp%d-%d", base, os.Getpid(), i))
		tmp, err = os.OpenFile(tmpName, os.O_WRONLY|os.O_CREATE|os.O_EXCL, perm)
		if err != nil && !os.IsExist(err) {
			return fmt.Errorf("create temp file in %s: %w", dir, err)
		}
	}
	if tmp == nil {
		return fmt.Errorf("create temp file in %s: %w", dir, err)
	}

	// An empty tmpName disables this cleanup after a successful rename.
	defer func() {
		if tmpName != "" {
			tmp.Close()
			os.Remove(tmpName)
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
