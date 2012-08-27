class String
  XML_MAP = {
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
    "'" => '&apos;',
    '"' => '&quot;'
  }

  def escape_xml
    self.gsub(/[&<>'"]/) do | match |
     XML_MAP[match]
    end
  end
end

