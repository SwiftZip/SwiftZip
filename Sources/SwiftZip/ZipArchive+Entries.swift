import zip

extension ZipArchive {
    public var entries: ZipArchiveEntries {
        return ZipArchiveEntries(archive: self)
    }
}

public struct ZipArchiveEntries {
    internal let archive: ZipArchive

    internal init(archive: ZipArchive) {
        self.archive = archive
    }
}

extension ZipArchiveEntries: RandomAccessCollection {
    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        do {
            return try archive.getEntryCount()
        } catch {
            return 0
        }
    }

    public subscript(position: Int) -> ZipEntry {
        do {
            return try archive.getEntry(index: position)
        } catch {
            preconditionFailure()
        }
    }
}
