require 'nkf'

class RomajiConverter

  VOWELS_INDEX = %w[a  i  u  e  o ]
  VOWELS_KANA  = %w[ア イ ウ エ オ]

  PREFIX_CHANGES = {
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

  PATTERN_CHANGES = {
    /n([^aeiou])/                   => 'nn\1',
    /([^aeiou])\1/                  => 'xtu\1',
    /([kg])w([aeiou])/              => '\1ux\2',
    /([td])w([aeiou])/              => '\1ox\2',
    /([sc])h([aeiou])/              => '\1ixy\2',
    /([kgszjtcdnhbpmrl])y([aeiou])/ => '\1ixy\2',
    /([td])h([aeiou])/              => '\1exy\2',
  }

  EXCEPTIONS = {
    '-'    => 'ー',
    'nn'   => 'ン',
    'xka'  => 'ヵ',
    'xke'  => 'ヶ',
    'xtu'  => 'ッ',
    'xtsu' => 'ッ',
    'xwa'  => 'ヮ',
    'shi'  => 'シ',
    'chi'  => 'チ',
  }

  attr_reader :determined

  def self.convert(str)
    new(str).results
  end

  def initialize(str)
    @buffer  = regulate(str)
    @determined = []

    convert
  end

  def convert
    return if eos?
    parse && convert
  end

  def parse
    parse_exception \
      || parse_pattern \
      || parse_prefix \
      || parse_vowel \
      || consume(1)
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

  def parse_pattern
    PATTERN_CHANGES.each do |pattern, replacement|
      r = %r{^#{pattern.source}}
      buffer = @buffer.sub(r, replacement)

      unless buffer == @buffer
        @buffer = buffer
        return true
      end
    end

    false
  end

  def parse_prefix
    PREFIX_CHANGES.each do |prefix, changes|
      if @buffer.start_with?(prefix)
        l = prefix.size
        vowel = @buffer[l]

        if (i = VOWELS_INDEX.index(vowel))
          consume(l + 1, changes[i])
          expand_long_sound(vowel)
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
      expand_long_sound(vowel)
      true
    else
      false
    end
  end

  def consume(len, replacement = nil)
    replacement = @buffer[0...len] if replacement.nil?
    @determined << replacement if replacement
    @buffer = @buffer[len..-1].to_s
    true
  end

  def expand_long_sound(vowel)
    return unless 'o' == vowel
    peak = @buffer[0]

    if 'h' == peak
      u1 = self.class.new(@buffer).tap(&:parse).determined
      if u1[0] == 'h'
        consume(1, false)
        @determined << ['オ']
      end
    elsif !(VOWELS_INDEX + %w[n y]).include?(peak)
      @determined << ['オ', 'ウ']
    end
  end

  def eos?
    @buffer.empty?
  end

  def results
    tree = ['']

    @determined.each do |det|
      if det.is_a?(Array)
        tree += tree.product(det).map(&:join)
      else
        tree.each { |t| t << det }
      end
    end

    tree
  end

  def regulate(str)
    NKF.nkf('-m0 -Z1 -w', str.to_s.downcase).gsub(/[^a-z-]+/, ' ')
  end

end

[
  'oyasai',
  'ono',
  'ohno',
  'omi',
  'otto',
  'kohama',
  'kondo',
  'kyari-pamyupamyu',
  'hohno',
  'hyogakyo',
].each do |romaji|
  puts romaji
  p RomajiConverter.convert(romaji)
end
# oyasai
# ["オヤサイ"]
# ono
# ["オノ", "オノオ", "オノウ"]
# ohno
# ["オノ", "オオノ", "オノオ", "オノウ", "オオノオ", "オオノウ"]
# omi
# ["オミ", "オオミ", "オウミ"]
# otto
# ["オット", "オオット", "オウット", "オットオ", "オットウ", "オオットオ", "オオットウ", "オウットオ", "オウットウ"]
# kohama
# ["コハマ"]
# kondo
# ["コンド", "コンドオ", "コンドウ"]
# kyari-pamyupamyu
# ["キャリーパミュパミュ"]
# hohno
# ["ホノ", "ホオノ", "ホノオ", "ホノウ", "ホオノオ", "ホオノウ"]
# hyogakyo
# ["ヒョガキョ", "ヒョオガキョ", "ヒョウガキョ", "ヒョガキョオ", "ヒョガキョウ", "ヒョオガキョオ", "ヒョオガキョウ", "ヒョウガキョオ", "ヒョウガキョウ"]
