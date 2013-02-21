# manual resource extractor

import pefile
import sys

def write_file(fn, data):
    with open(fn, "wb") as fw:
        fw.write(data)

def enum_resource(pe):
    if hasattr(pe, 'DIRECTORY_ENTRY_RESOURCE'):
        for resource_type in pe.DIRECTORY_ENTRY_RESOURCE.entries:
            if hasattr(resource_type, 'directory'):
                for resource_id in resource_type.directory.entries:
                    if hasattr(resource_id, 'directory'):
                        for resource_lang in resource_id.directory.entries:
                            yield resource_lang.data.struct.OffsetToData, resource_lang.data.struct.Size, resource_type.name, resource_type.id
    return

def main():
    fn = sys.argv[1]
    pe = pefile.PE(fn)
    count = 0
    _min = pe.OPTIONAL_HEADER.ImageBase
    _max = 0
    for rva, size, typename , typeid in enum_resource(pe):
        count += 1
        data = pe.get_data(rva, size)
        if typename is None:
            type_ = pefile.RESOURCE_TYPE[typeid]
        else:
            type_ = typename
        write_file("%s%03i.%s" % (fn, count, type_), data)

if __name__ == "__main__":
    main()