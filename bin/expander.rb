require 'erb'

# basically the full program now, a File.read would just be to clean it up a
# bit
#
# a good improvements would be outputting a command on the last line for vim to read
# to know where to put the cursor. I dont want to work on that though
module Expander
  def self.join_with_indentation indentation, sep, els
    els.join(sep + " " * indentation)
  end

  def self.word_objects words
    join_with_indentation(
      6,
      ",\n",
      words.map {|w| %Q({"ja": "#{w[0]}", "reading": "#{w[1]}", "en": "#{w[2]}"}) },
    )
  end

  def self.render
    args          = ARGV[0].split(".")
    ft            = args[0]
    @indentation  = " " * args[1].match(/^\s*/)[0].length
    key           = args[1].strip
    template_args = args[2..-1]

    puts get_template(ft, key, template_args).result(binding)
  end

  def self.get_template ft, key, template_args
    template = case ft
               when 'json'
                 json_templates ft, key, template_args
               end
    template ||= try_generic ft, key, template_args # missing key in ft or missing ft altogether

    ERB.new( @indentation + template.split("\n").join("\n" + @indentation) )
  end

  def self.json_templates ft, key, template_args
    case key
    when 'j'
      @words = template_args[3..-1].each_slice(3).to_a
      <<-EOF
{
  "kanji": "<%= template_args[0].strip %>",
  "on_reading": "<%= template_args[1] %>",
  "meaning": "<%= template_args[2] %>",
  "words": [
    <%= word_objects @words %>
  ]
},
      EOF
    end
  end

  def self.try_generic ft, key, template_args
    case key
    when 'a'
      "[#{template_args.join(', ')}]"
    when 'aq'
      "[#{template_args.map(&:inspect).join(', ')}]"
    when 'u'
      template_args.map(&:upcase).join('_')
    when 's'
      template_args.join('_')
    when 'q'
      %Q("#{ template_args[0] }")
    when 'ktk'
<<-EOF
"#{ template_args[0] }": {

},
EOF
    else
      raise "No template defined for filetype #{ft} with key #{key}. No generic template for key #{key}"
    end
  end
end

Expander.render

  # j.my.cool.test.with.some.word.and.another.word
  # aq.one.two.three
