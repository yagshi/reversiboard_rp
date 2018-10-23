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
  if $b.can_put(x: bx, y: by, color: :white)
    $b.put(x: bx, y: by, color: :white)   # 左クリック→白
    $playerTurn = false
    x2, y2 = -1, -1
    8.times {|y|
      8.times {|x|
        if $b.can_put(x: x, y: y, color: :black)
          x2 = x
          y2 = y
          break
        end
      }
    }
    $b.put(x: x2, y: y2, color: :black)
    $playerTurn = true
  end
  puts "white=%d" % ($b.count(color: :white))
  puts "black=%d" % ($b.count(color: :black))
end
