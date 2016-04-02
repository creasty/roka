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
# ["オンオ", "オンオウ", "オノ", "オノウ", "オオンオ", "オオンオウ", "オオノ", "オオノウ", "オウンオ", "オウンオウ", "オウノ", "オウノウ"]
# ohno
# ["オンオ", "オンオウ", "オノ", "オノウ", "オオンオ", "オオンオウ", "オオノ", "オオノウ"]
# omi
# ["オミ"]
# otto
# ["オット", "オットウ"]
# kohama
# ["コハマ"]
# kondo
# ["コンド", "コンドウ"]
# kyari-pamyupamyu
# ["キャリーパミュパミュ"]
# hohno
# ["ホンオ", "ホンオウ", "ホノ", "ホノウ", "ホオンオ", "ホオンオウ", "ホオノ", "ホオノウ"]
# hyougaki
# ["ヒョウガキ"]
  ```

### CLI

```sh
$ roka koniro kono konno konyakku konnyaku ann koh kondo yuna sato
--- koniro
コンイロ
コンイロウ
コニロ
コニロウ
--- kono
コンオ
コンオウ
コノ
コノウ
コオンオ
コオンオウ
コオノ
コオノウ
コウンオ
コウンオウ
コウノ
コウノウ
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
--- yuna
ユンア
ユナ
ユウンア
ユウナ
--- sato
サト
サトウ
```


License
-------

This project is released under the MIT license. See `LICENSE` file for details.
