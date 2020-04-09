# libzip API mapping

|  | libzip | SwiftZip | description |
| - | ------ | -------- | ----------- |
| ⛔️ | [zip_add](https://libzip.org/documentation/zip_add.html) | obsolete | add file to zip archive or replace file in zip archive (obsolete interface) |
| ⛔️ | [zip_add_dir](https://libzip.org/documentation/zip_add_dir.html) | obsolete | add directory to zip archive (obsolete interface) |
| ✅ | [zip_close](https://libzip.org/documentation/zip_close.html) | `ZipArchive.close` | close zip archive |
| ✅ | [zip_delete](https://libzip.org/documentation/zip_delete.html) | `ZipMutableEntry.delete` | delete file from zip archive |
| ✅ | [zip_dir_add](https://libzip.org/documentation/zip_dir_add.html) | `ZipArchive.addDirectory` | add directory to zip archive |
| ✅ | [zip_discard](https://libzip.org/documentation/zip_discard.html) | `ZipArchive.discard` | close zip archive and discard changes |
| ❌ | [zip_errors](https://libzip.org/documentation/zip_errors.html) | missing | list of all libzip error codes |
| 📦 | [zip_error_clear](https://libzip.org/documentation/zip_error_clear.html) | used internally | clear error state for archive or file |
| ❌ | [zip_error_code_system](https://libzip.org/documentation/zip_error_code_system.html) | missing | get operating system error part of zip_error |
| ❌ | [zip_error_code_zip](https://libzip.org/documentation/zip_error_code_zip.html) | missing | get libzip error part of zip_error |
| ❌ | [zip_error_fini](https://libzip.org/documentation/zip_error_fini.html) | missing | clean up zip_error structure |
| ⛔️ | [zip_error_get](https://libzip.org/documentation/zip_error_get.html) | obsolete | get error codes for archive or file (obsolete interface) |
| ⛔️ | [zip_error_get_sys_type](https://libzip.org/documentation/zip_error_get_sys_type.html) | obsolete | get type of system error code (obsolete interface) |
| ❌ | [zip_error_init](https://libzip.org/documentation/zip_error_init.html) | missing | initialize zip_error structure |
| ❌ | [zip_error_init_with_code](https://libzip.org/documentation/zip_error_init_with_code.html) | missing | initialize zip_error structure |
| ❌ | [zip_error_set](https://libzip.org/documentation/zip_error_set.html) | missing | fill in zip_error structure |
| ✅ | [zip_error_strerror](https://libzip.org/documentation/zip_error_strerror.html) | `ZipError.errorDescription` | create human-readable string for zip_error |
| ❌ | [zip_error_system_type](https://libzip.org/documentation/zip_error_system_type.html) | missing | return type of system error |
| ❌ | [zip_error_to_data](https://libzip.org/documentation/zip_error_to_data.html) | missing | convert zip_error to return value suitable for ZIP_SOURCE_ERROR |
| ⛔️ | [zip_error_to_str](https://libzip.org/documentation/zip_error_to_str.html) | obsolete | get string representation of zip error (obsolete interface) |
| ✅ | [zip_fclose](https://libzip.org/documentation/zip_fclose.html) | `ZipEntryReader.close` | close file in zip archive |
| ✅ | [zip_fdopen](https://libzip.org/documentation/zip_fdopen.html) | `ZipArchive.init` | open zip archive using open file descriptor |
| ✅ | [zip_file_add](https://libzip.org/documentation/zip_file_add.html) | `ZipArchive.addFile` | add file to zip archive or replace file in zip archive |
| 📦 | [zip_file_error_clear](https://libzip.org/documentation/zip_file_error_clear.html) | used internally | clear error state for archive or file |
| ⛔️ | [zip_file_error_get](https://libzip.org/documentation/zip_file_error_get.html) | obsolete | get error codes for archive or file (obsolete interface) |
| ✅ | [zip_file_extra_fields_count](https://libzip.org/documentation/zip_file_extra_fields_count.html) | `ZipEntry.getExtraFieldsCount` | count extra fields for file in zip |
| ✅ | [zip_file_extra_fields_count_by_id](https://libzip.org/documentation/zip_file_extra_fields_count_by_id.html) | `ZipEntry.getExtraFieldsCount` | count extra fields for file in zip |
| ✅ | [zip_file_extra_field_delete](https://libzip.org/documentation/zip_file_extra_field_delete.html) | `ZipMutableEntry.deleteExtraField` | delete extra field for file in zip |
| ✅ | [zip_file_extra_field_delete_by_id](https://libzip.org/documentation/zip_file_extra_field_delete_by_id.html) | `ZipMutableEntry.deleteExtraField` | delete extra field for file in zip |
| ✅ | [zip_file_extra_field_get](https://libzip.org/documentation/zip_file_extra_field_get.html) | `ZipEntry.getExtraField` | get extra field for file in zip |
| ✅ | [zip_file_extra_field_get_by_id](https://libzip.org/documentation/zip_file_extra_field_get_by_id.html) | `ZipEntry.getExtraField` | get extra field for file in zip |
| ✅ | [zip_file_extra_field_set](https://libzip.org/documentation/zip_file_extra_field_set.html) | `ZipMutableEntry.setExtraField` | set extra field for file in zip |
| ✅ | [zip_file_get_comment](https://libzip.org/documentation/zip_file_get_comment.html) | `ZipEntry.getComment` | get comment for file in zip |
| 📦 | [zip_file_get_error](https://libzip.org/documentation/zip_file_get_error.html) | used internally | extract zip_error from zip_file |
| ✅ | [zip_file_get_external_attributes](https://libzip.org/documentation/zip_file_get_external_attributes.html) | `ZipEntry.getExternalAttributes` | get external attributes for file in zip |
| ✅ | [zip_file_rename](https://libzip.org/documentation/zip_file_rename.html) | `ZipMutableEntry.rename` | rename file in zip archive |
| ✅ | [zip_file_replace](https://libzip.org/documentation/zip_file_replace.html) | `ZipMutableEntry.replace` | add file to zip archive or replace file in zip archive |
| ✅ | [zip_file_set_comment](https://libzip.org/documentation/zip_file_set_comment.html) | `ZipMutableEntry.setComment` | set comment for file in zip |
| 🚫 | [zip_file_set_dostime](https://libzip.org/documentation/zip_file_set_dostime.html) | see `file_set_mtime` | set last modification time (mtime) for file in zip |
| ✅ | [zip_file_set_encryption](https://libzip.org/documentation/zip_file_set_encryption.html) | `ZipMutableEntry.setEncryption` | set encryption method for file in zip |
| ✅ | [zip_file_set_external_attributes](https://libzip.org/documentation/zip_file_set_external_attributes.html) | `ZipMutableEntry.setExternalAttributes` | set external attributes for file in zip |
| ✅ | [zip_file_set_mtime](https://libzip.org/documentation/zip_file_set_mtime.html) | `ZipMutableEntry.setModificationDate` | set last modification time (mtime) for file in zip |
| 🚫 | [zip_file_strerror](https://libzip.org/documentation/zip_file_strerror.html) | not relevant | get string representation for a zip error |
| ✅ | [zip_fopen](https://libzip.org/documentation/zip_fopen.html) | `ZipArchive.open` | open file in zip archive for reading |
| ✅ | [zip_fopen_encrypted](https://libzip.org/documentation/zip_fopen_encrypted.html) | `ZipArchive.open` | open encrypted file in zip archive for reading |
| ✅ | [zip_fopen_index](https://libzip.org/documentation/zip_fopen_index.html) | `ZipEntry.getExternalAttributes` | open file in zip archive for reading |
| ✅ | [zip_fopen_index_encrypted](https://libzip.org/documentation/zip_fopen_index_encrypted.html) | `ZipEntry.getExternalAttributes` | open encrypted file in zip archive for reading |
| ✅ | [zip_fread](https://libzip.org/documentation/zip_fread.html) | `ZipEntryReader.read` | read from file |
| ✅ | [zip_fseek](https://libzip.org/documentation/zip_fseek.html) | `ZipEntryReader.seek` | seek in file |
| ✅ | [zip_ftell](https://libzip.org/documentation/zip_ftell.html) | `ZipEntryReader.tell` | tell position in file |
| ✅ | [zip_get_archive_comment](https://libzip.org/documentation/zip_get_archive_comment.html) | `ZipArchive.getComment` | get zip archive comment |
| ❌ | [zip_get_archive_flag](https://libzip.org/documentation/zip_get_archive_flag.html) | missing | get status flags for zip |
| 📦 | [zip_get_error](https://libzip.org/documentation/zip_get_error.html) | used internally | get zip error for archive |
| ⛔️ | [zip_get_file_comment](https://libzip.org/documentation/zip_get_file_comment.html) | obsolete | get comment for file in zip (obsolete interface) |
| ✅ | [zip_get_name](https://libzip.org/documentation/zip_get_name.html) | `ZipEntry.getName` | get name of file by index |
| ✅ | [zip_get_num_entries](https://libzip.org/documentation/zip_get_num_entries.html) | `ZipArchive.getEntryCount` | get number of files in archive |
| ⛔️ | [zip_get_num_files](https://libzip.org/documentation/zip_get_num_files.html) | obsolete | get number of files in archive (obsolete interface) |
| ❌ | [zip_libzip_version](https://libzip.org/documentation/zip_libzip_version.html) | missing | return run-time version of library |
| ✅ | [zip_name_locate](https://libzip.org/documentation/zip_name_locate.html) | `ZipArchive.locate` | get index of file by name |
| ✅ | [zip_open](https://libzip.org/documentation/zip_open.html) | `ZipArchive.init` | open zip archive |
| ✅ | [zip_open_from_source](https://libzip.org/documentation/zip_open_from_source.html) | `ZipArchive.init` | open zip archive |
| ⛔️ | [zip_register_progress_callback](https://libzip.org/documentation/zip_register_progress_callback.html) | obsolete | provide updates during zip_close (obsolete interface) |
| ❌ | [zip_register_progress_callback_with_state](https://libzip.org/documentation/zip_register_progress_callback_with_state.html) | missing | provide updates during zip_close |
| ⛔️ | [zip_rename](https://libzip.org/documentation/zip_rename.html) | obsolete | rename file in zip archive (obsolete interface) |
| ⛔️ | [zip_replace](https://libzip.org/documentation/zip_replace.html) | obsolete | add file to zip archive or replace file in zip archive (obsolete interface) |
| ✅ | [zip_set_archive_comment](https://libzip.org/documentation/zip_set_archive_comment.html) | `ZipArchive.setComment` | set zip archive comment |
| ❌ | [zip_set_archive_flag](https://libzip.org/documentation/zip_set_archive_flag.html) | missing | set zip archive flag |
| ✅ | [zip_set_default_password](https://libzip.org/documentation/zip_set_default_password.html) | `ZipArchive.setDefaultPassword` | set default password for encrypted files in zip |
| ⛔️ | [zip_set_file_comment](https://libzip.org/documentation/zip_set_file_comment.html) | obsolete | set comment for file in zip (obsolete interface) |
| ✅ | [zip_set_file_compression](https://libzip.org/documentation/zip_set_file_compression.html) | `ZipMutableEntry.setCompression` | set compression method for file in zip |
| ✅ | [zip_source](https://libzip.org/documentation/zip_source.html) | `ZipSource` | zip data source structure |
| ❌ | [zip_source_begin_write](https://libzip.org/documentation/zip_source_begin_write.html) | missing | prepare zip source for writing |
| ❌ | [zip_source_begin_write_cloning](https://libzip.org/documentation/zip_source_begin_write_cloning.html) | missing | prepare zip source for writing |
| 🚫 | [zip_source_buffer](https://libzip.org/documentation/zip_source_buffer.html) | not relevant | create zip data source from buffer |
| ✅ | [zip_source_buffer_create](https://libzip.org/documentation/zip_source_buffer_create.html) | `ZipSource.init` | create zip data source from buffer |
| 🚫 | [zip_source_buffer_fragment](https://libzip.org/documentation/zip_source_buffer_fragment.html) | not relevant | create zip data source from multiple buffer |
| ❌ | [zip_source_buffer_fragment_create](https://libzip.org/documentation/zip_source_buffer_fragment_create.html) | missing | create zip data source from multiple buffer |
| ❌ | [zip_source_close](https://libzip.org/documentation/zip_source_close.html) | missing | open zip_source (which was open for reading) |
| ❌ | [zip_source_commit_write](https://libzip.org/documentation/zip_source_commit_write.html) | missing | finalize changes to zip source |
| ❌ | [zip_source_error](https://libzip.org/documentation/zip_source_error.html) | missing | get zip error for data source |
| 🚫 | [zip_source_file](https://libzip.org/documentation/zip_source_file.html) | not relevant | create data source from a file |
| 🚫 | [zip_source_filep](https://libzip.org/documentation/zip_source_filep.html) | not relevant | create data source from FILE * |
| ✅ | [zip_source_filep_create](https://libzip.org/documentation/zip_source_filep_create.html) | `ZipSource.init` | create data source from FILE * |
| ✅ | [zip_source_file_create](https://libzip.org/documentation/zip_source_file_create.html) | `ZipSource.init` | create data source from a file |
| ✅ | [zip_source_free](https://libzip.org/documentation/zip_source_free.html) | `ZipSource.deinit` | free zip data source |
| 🚫 | [zip_source_function](https://libzip.org/documentation/zip_source_function.html) | not relevant | create data source from function |
| ✅ | [zip_source_function_create](https://libzip.org/documentation/zip_source_function_create.html) | `ZipSource.init` | create data source from function |
| ❌ | [zip_source_is_deleted](https://libzip.org/documentation/zip_source_is_deleted.html) | missing | check if zip_source is deleted |
| 📦 | [zip_source_keep](https://libzip.org/documentation/zip_source_keep.html) | used internally | increment reference count of zip data source |
| ❌ | [zip_source_make_command_bitmap](https://libzip.org/documentation/zip_source_make_command_bitmap.html) | missing | create bitmap of supported source operations |
| ❌ | [zip_source_open](https://libzip.org/documentation/zip_source_open.html) | missing | open zip_source for reading |
| ❌ | [zip_source_read](https://libzip.org/documentation/zip_source_read.html) | missing | read data from zip source |
| ❌ | [zip_source_rollback_write](https://libzip.org/documentation/zip_source_rollback_write.html) | missing | undo changes to zip source |
| ❌ | [zip_source_seek](https://libzip.org/documentation/zip_source_seek.html) | missing | set read offset in zip source |
| ❌ | [zip_source_seek_compute_offset](https://libzip.org/documentation/zip_source_seek_compute_offset.html) | missing | validate arguments and compute offset |
| ❌ | [zip_source_seek_write](https://libzip.org/documentation/zip_source_seek_write.html) | missing | set write offset in zip source |
| ❌ | [zip_source_stat](https://libzip.org/documentation/zip_source_stat.html) | missing | get information about zip_source |
| ❌ | [zip_source_tell](https://libzip.org/documentation/zip_source_tell.html) | missing | report current read offset in zip source |
| ❌ | [zip_source_tell_write](https://libzip.org/documentation/zip_source_tell_write.html) | missing | report current write offset in zip source |
| 🚫 | [zip_source_win32a](https://libzip.org/documentation/zip_source_win32a.html) | not relevant | create data source from a Windows ANSI file name |
| 🏳️ | [zip_source_win32a_create](https://libzip.org/documentation/zip_source_win32a_create.html) | windows-specific | create data source from a Windows ANSI file name |
| 🚫 | [zip_source_win32handle](https://libzip.org/documentation/zip_source_win32handle.html) | not relevant | create data source from a Windows file handle |
| 🏳️ | [zip_source_win32handle_create](https://libzip.org/documentation/zip_source_win32handle_create.html) | windows-specific | create data source from a Windows file handle |
| 🚫 | [zip_source_win32w](https://libzip.org/documentation/zip_source_win32w.html) | not relevant | create data source from a Windows Unicode file name |
| 🏳️ | [zip_source_win32w_create](https://libzip.org/documentation/zip_source_win32w_create.html) | windows-specific | create data source from a Windows Unicode file name |
| ❌ | [zip_source_write](https://libzip.org/documentation/zip_source_write.html) | missing | write data to zip source |
| ❌ | [zip_source_zip](https://libzip.org/documentation/zip_source_zip.html) | missing | create data source from zip file |
| ✅ | [zip_stat](https://libzip.org/documentation/zip_stat.html) | `ZipArchive.stat` | get information about file |
| ✅ | [zip_stat_index](https://libzip.org/documentation/zip_stat_index.html) | `ZipEntry.stat` | get information about file |
| 📦 | [zip_stat_init](https://libzip.org/documentation/zip_stat_init.html) | used internally | initialize zip_stat structure |
| 🚫 | [zip_strerror](https://libzip.org/documentation/zip_strerror.html) | not relevant | get string representation for a zip error |
| ✅ | [zip_unchange](https://libzip.org/documentation/zip_unchange.html) | `ZipMutableEntry.unchange` | undo changes to file in zip archive |
| ✅ | [zip_unchange_all](https://libzip.org/documentation/zip_unchange_all.html) | `ZipArchive.unchangeAll` | undo all changes in a zip archive |
| ✅ | [zip_unchange_archive](https://libzip.org/documentation/zip_unchange_archive.html) | `ZipArchive.unchangeGlobals` | undo global changes to zip archive |
