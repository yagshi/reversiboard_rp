#!/usr/bin/ruby
#coding: utf-8
require "./reversiboard"          # ←この一行を入れる

$playerTurn = true

def setup
  $b = ReversiBoard.new(self)     # リバーシ盤作成
end

def draw
  $b.show                         # リバーシ盤表示
end

def mouse_clicked
  return unless $playerTurn
  bx, by = $b.mouse2board(x: mouseX, y: mouseY)
  if $b.can_put?(x: bx, y: by, color: :white)
    $b.put(x: bx, y: by, color: :white)
    $playerTurn = false
    # 打てる場所を探して最初の位置に打つだけアルゴリズム (意外と強い?)
    Kernel.loop {
      p = $b.find_places(color: :black)
      break if p.length == 0
      $b.put(x: p[0][0], y: p[0][1], color: :black)
      break if $b.find_places(color: :white).length > 0
    }
    $playerTurn = true
  end
  w = $b.count(color: :white)
  b = $b.count(color: :black)
  puts "white: %d   black: %d" % [w, b]
  break if w + b >= 64
end
