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
  'hyougaki',
].each do |romaji|
  puts romaji
  p Roka.convert(romaji)
end
# oyasai
# ["オヤサイ"]
# ono
# ["オンオ", "オノ", "オオンオ", "オオノ", "オウンオ", "オウノ"]
# ohno
# ["オンオ", "オノ", "オオンオ", "オオノ"]
# omi
# ["オミ"]
# otto
# ["オット"]
# kohama
# ["コハマ"]
# kondo
# ["コンド", "コンドウ"]
# kyari-pamyupamyu
# ["キャリーパミュパミュ"]
# hohno
# ["ホンオ", "ホノ", "ホオンオ", "ホオノ"]
# hyougaki
# ["ヒョウガキ"]
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
