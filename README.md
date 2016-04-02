roka
====

Romaji to kana converter


Installation
------------

Add this line to your Gemfile:

```ruby
gem 'roka'
```


Usage
-----

```ruby
require 'roka'

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
  p Roka.convert(romaji)
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
# hyogaki
# ["ヒョガキ", "ヒョオガキ", "ヒョウガキ"]
  ```

### CLI

```sh
$ roka koniro kono konno konyakku konnyaku ann koh kondo
--- koniro
コンイロ
コニロ
--- kono
コンオ
コノ
コオンオ
コオノ
コウンオ
コウノ
--- konno
コンノ
コンノウ
--- konyakku
コニャック
--- konnyaku
コンニャク
--- ann
アン
--- koh
コ
コウ
--- kondo
コンド
コンドウ
```


License
-------

This project is released under the MIT license. See `LICENSE` file for details.
