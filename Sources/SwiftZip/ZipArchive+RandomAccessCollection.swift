import zip

extension ZipArchive: RandomAccessCollection {
    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        do {
            return try getEntryCount()
        } catch {
            return 0
        }
    }

    public subscript(position: Int) -> ZipEntry {
        do {
            return try getEntry(index: position)
        } catch {
            preconditionFailure()
        }
    }
}
