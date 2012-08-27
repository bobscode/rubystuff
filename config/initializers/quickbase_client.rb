require 'QuickBaseClient'

class QuickBase::Client

  def setFieldValues(fields, editRecord=true)
    if fields.is_a?(Hash)
      clearFieldValuePairList
      fields.each { |fieldName, fieldValue|
        if (fieldName.is_a? String)
          addFieldValuePair(fieldName, nil, nil, fieldValue)
        elsif (fieldName.is_a? Integer)
          addFieldValuePair(nil, fieldName, nil, fieldValue)
        end
      }
      if editRecord and @dbid and @rid
        editRecord(@dbid, @rid, @fvlist)
      end
    end
  end

end

class QuickBase::Client::FieldValuePairXML
  def encodeFileContentsForUpload(fileNameOrFileContents)
    if fileNameOrFileContents
      begin
        readable = FileTest.readable?(fileNameOrFileContents)
      rescue ArgumentError
        readable = false
      end
      if readable
        f = File.new(fileNameOrFileContents, "r")
        if f
          encodedFileContents = ""
          f.binmode
          buffer = f.read(60)
          while buffer
            encodedFileContents << [buffer].pack('m').tr("\r\n", '')
            buffer = f.read(60)
          end
          f.close
          return encodedFileContents
        end
      elsif fileNameOrFileContents.is_a?(String)
        encodedFileContents = ""
        buffer = fileNameOrFileContents.slice!(0, 60)
        while buffer and buffer.length > 0
          buffer = buffer.to_s
          encodedFileContents << [buffer].pack('m').tr("\r\n", '')
          buffer = fileNameOrFileContents.slice!(0, 60)
        end
        return encodedFileContents
      end
    end
    nil
  end

end