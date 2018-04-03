require 'binary_struct'
require 'stringio'

require 'rufus/lru'

module VirtFS::XFS
  # ////////////////////////////////////////////////////////////////////////////
  # // Class.
 
  class BmapBTreeBlock
    SHORT_HDR_NOCRC = BinaryStruct.new([
      #  Common BTree Block header information
      'I>',  'magic_num',          # magic number of the btree block type
      'S>',  'level',              # level number.  0 is a leaf
      'S>',  'num_recs',           # current # of data records
      #
      #  Short Section
      #
      'I>',  'left_sibling',       #
      'I>',  'right_sibling',      #
    ])
    SIZEOF_SHORT_HDR_NOCRC = SHORT_HDR_NOCRC.size

    SHORT_HDR = BinaryStruct.new([
      #  Common BTree Block header information
      'I>',  'magic_num',          # magic number of the btree block type
      'S>',  'level',              # level number.  0 is a leaf
      'S>',  'num_recs',           # current # of data records
      #
      #  Short Section
      #
      'I>',  'left_sibling',       #
      'I>',  'right_sibling',      #
      'Q>',  'block_num',          #
      'Q>',  'lsn',                #
      'a16', 'uuid',               #
      'I>',  'owner',              #
      'I>',  'crc',                #
    ])
    SIZEOF_SHORT_HDR = SHORT_HDR.size

    LONG_HDR_NOCRC = BinaryStruct.new([
      #  Common BTree Block header information
      'I>',  'magic_num',          # magic number of the btree block type
      'S>',  'level',              # level number.  0 is a leaf
      'S>',  'num_recs',           # current # of data records
      #
      #  Long Section
      #
      'Q>',  'left_sibling',       #
      'Q>',  'right_sibling',      #
    ])
    SIZEOF_LONG_HDR_NOCRC = LONG_HDR_NOCRC.size

    LONG_HDR = BinaryStruct.new([
      #  Common BTree Block header information
      'I>',  'magic_num',          # magic number of the btree block type
      'S>',  'level',              # level number.  0 is a leaf
      'S>',  'num_recs',           # current # of data records
      #
      #  Long Section
      #
      'Q>',  'left_sibling',       #
      'Q>',  'right_sibling',      #
      'Q>',  'block_num',          #
      'Q>',  'lsn',                #
      'a16', 'uuid',               #
      'Q>',  'owner',              #
      'I>',  'crc',                #
      'I>',  'pad',                #
    ])
    SIZEOF_LONG_HDR = LONG_HDR.size

    XFS_BTREE_LONG_PTRS = 1
    XFS_BMAP_MAGIC      = 0x424d4150
    XFS_BMAP_CRC_MAGIC  = 0x424d4133
    # // initialize
    attr_reader :level, :number_records, :header_size, :buffer, :left_sibling, :right_sibling

    def initialize(buffer, sb)
      @sb = sb
      if defined? XFS_BTREE_LONG_PTRS
        if @sb.version_has_crc?
          @btree_block = LONG_HDR.decode(buffer)
        else
          @btree_block = LONG_HDR_NOCRC.decode(buffer)
        end
      else
        if sb.version_has_crc?
          @btree_block = SHORT_HDR.decode(buffer)
        else
          @btree_block = SHORT_HDR_NOCRC.decode(buffer)
        end
      end
      @header_size    = btree_block_length
      @number_records = @btree_block['num_recs']
      @level          = @btree_block['level']
      raise "Invalid BTreeBlock" unless (@btree_block['magic_num'] == XFS_BMAP_MAGIC) ||
                                        (@btree_block['magic_num'] == XFS_BMAP_CRC_MAGIC)
      @left_sibling  = @btree_block['left_sibling']
      @right_sibling = @btree_block['right_sibling']
      @buffer        = buffer
    end

    def btree_block_length
      if defined? XFS_BTREE_LONG_PTRS
        if @sb.version_has_crc?
          len = SIZEOF_LONG_HDR
        else
          len = SIZEOF_LONG_HDR_NOCRC
        end
      else
        if @sb.version_has_crc?
          len = SIZEOF_SHORT_HDR
        else
          len = SIZEOF_SHORT_HDR_NOCRC
        end
      end
      len
    end
  end # class BTreeBlock
end # module VirtFS::XFS
