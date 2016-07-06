require 'nkf'

class Roka::Converter

  VOWELS_INDEX = %w[a  i  u  e  o ]
  VOWELS_KANA  = %w[ア イ ウ エ オ]

  SOUND_CHANGES = {
    'ts' => %w[ツァ ツィ ツ   ツェ ツォ],

    'xy' => %w[ャ   ィ   ュ   ェ   ョ  ],
    'x'  => %w[ァ   ィ   ゥ   ェ   ォ  ],

    'k'  => %w[カ   キ   ク   ケ   コ  ],
    's'  => %w[サ   シ   ス   セ   ソ  ],
    't'  => %w[タ   チ   ツ   テ   ト  ],
    'n'  => %w[ナ   ニ   ヌ   ネ   ノ  ],
    'h'  => %w[ハ   ヒ   フ   ヘ   ホ  ],
    'm'  => %w[マ   ミ   ム   メ   モ  ],
    'y'  => %w[ヤ   イ   ユ   イェ ヨ  ],
    'r'  => %w[ラ   リ   ル   レ   ロ  ],
    'l'  => %w[ラ   リ   ル   レ   ロ  ],
    'w'  => %w[ワ   ウィ ウ   ウェ ヲ  ],

    'g'  => %w[ガ   ギ   グ   ゲ   ゴ  ],
    'z'  => %w[ザ   ジ   ズ   ゼ   ゾ  ],
    'j'  => %w[ジャ ジ   ジュ ジェ ジョ],
    'd'  => %w[ダ   ヂ   ヅ   デ   ド  ],
    'b'  => %w[バ   ビ   ブ   ベ   ボ  ],
    'v'  => %w[ヴァ ヴィ ヴ   ヴェ ヴォ],

    'f'  => %w[ファ フィ フ   フェ フォ],
    'p'  => %w[パ   ピ   プ   ペ   ポ  ],

    'c'  => %w[カ   シ   ク   セ   コ  ],
  }

  PREFIX_CHANGES = {
    /^([kg])w([aeiou])/              => '\1ux\2',
    /^([td])w([aeiou])/              => '\1ox\2',
    /^sh([aeiou])/                   => 'sixy\1',
    /^ch([aeiou])/                   => 'tixy\1',
    /^([kgszjtcdnhbpmrl])y([aeiou])/ => '\1ixy\2',
    /^([td])h([aeiou])/              => '\1exy\2',
    /^([bcdfghjklmnprstvwxyz])\1/    => 'xtu\1',
    /^nn\b/                          => 'n',
    /^([^aeiou]o)([^h]?)\b/          => '\1h\2',
  }

  EXCEPTIONS = {
    '-'    => 'ー',
    'xka'  => 'ヵ',
    'xke'  => 'ヶ',
    'xtu'  => 'ッ',
    'xtsu' => 'ッ',
    'xwa'  => 'ヮ',
    'shi'  => 'シ',
    'chi'  => 'チ',
  }

  attr_reader :determined

  def initialize(str)
    @buffer     = regulate(str)
    @determined = []
  end

  def convert
    return if eos?
    parse && convert
  end

  def parse
    parse_exception \
      || parse_prefix \
      || parse_sound \
      || parse_vowel \
      || parse_last
  end

  def parse_exception
    EXCEPTIONS.each do |seq, replacement|
      if @buffer.start_with?(seq)
        consume(seq.size, replacement)
        return true
      end
    end

    false
  end

  def parse_prefix
    PREFIX_CHANGES.each do |pattern, replacement|
      buffer = @buffer.sub(pattern, replacement)

      unless buffer == @buffer
        @buffer = buffer
        return true
      end
    end

    false
  end

  def parse_sound
    SOUND_CHANGES.each do |prefix, changes|
      if @buffer.start_with?(prefix)
        l = prefix.size
        vowel = @buffer[l]

        if (i = VOWELS_INDEX.index(vowel))
          if 'n' == @buffer[0] && 'x' != @buffer[l + 1] && 'ン' != @determined[@determined.size - 1]
            consume(l + 1, ['ン' + VOWELS_KANA[i], changes[i]])
          else
            consume(l + 1, changes[i])
          end
          expand_long_sound(prefix, vowel)
          return true
        end
      end
    end

    false
  end

  def parse_vowel(consonant = nil)
    vowel = @buffer[0]
    if (i = VOWELS_INDEX.index(vowel))
      consume(1, VOWELS_KANA[i])
      expand_long_sound(nil, vowel)
      true
    else
      false
    end
  end

  def parse_last
    if 'n' == @buffer[0]
      consume(1, 'ン')
    else
      consume(1, @buffer[0])
    end
  end

  def consume(len, replacement = nil)
    replacement = @buffer[0...len] if replacement.nil?
    @determined << replacement if replacement
    @buffer = @buffer[len..-1].to_s
    true
  end

  def expand_long_sound(prefix, vowel)
    c = @buffer[0]

    case vowel
    when 'o'
      if 'h' == c && !@buffer[1]
        consume(1, ['', 'ウ'])
      elsif 'h' == c
        d, _ = peak
        if d[0] == 'h'
          consume(1, ['', 'オ'])
        end
      elsif !(VOWELS_INDEX + %w[y]).include?(c) && ('n' == c && 'o' == @buffer[1])
        @determined << ['', 'オ', 'ウ']
      end
    when 'u'
      @determined << ['', 'ウ'] if 'y' == prefix
    end
  end

  def eos?
    @buffer.empty?
  end

  def results
    tree = ['']

    @determined.each do |det|
      if det.is_a?(Array)
        tree = tree.product(det).map(&:join)
      else
        tree.each { |t| t << det }
      end
    end

    tree
  end

  def regulate(str)
    NKF.nkf('-m0 -Z1 -w', str.to_s.downcase)
  end

  def peak(_buffer = nil)
    determined  = @determined
    buffer      = @buffer
    @determined = []
    @buffer = _buffer unless _buffer.nil?
    parse while @determined.empty? || !eos?
    [@determined, @buffer]
  ensure
    @determined = determined
    @buffer     = buffer
  end

end
