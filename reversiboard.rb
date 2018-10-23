# coding: utf-8

class ReversiBoard
  attr_accessor :data    # 0=空, 1=白, 2 =黒
  CSize = 80    # 1マスのサイズ
  Padding = 16
  Black = [0, 0, 0]
  White = [255, 255, 255]
  Dir8 = [[1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1], [0, 1], [1, 1]]
  @rp           # ruby processing インスタンス

  # x, y 座標に石を配置。color は :black もしくは :white
  # autoflip: true にするとひっくり返す。
  def put(x: 0, y: 0, color: 0, autoflip: false)
    raise "position out of range" if x < 0 || y < 0 || x > 7 || y > 7
    case color
    when :black
      @data[y][x] = 2
    when :white
      @data[y][x] = 1
    end
  end

  def initialize(aRp)
    @rp = aRp
    @rp.size CSize * 8 + Padding * 2, CSize * 8 + Padding * 2
    @data = Array.new(8).map {Array.new(8).map {0}}
    put(x: 3, y: 3, color: :white)
    put(x: 4, y: 4, color: :white)
    put(x: 3, y: 4, color: :black)
    put(x: 4, y: 3, color: :black)
  end

  def show
    @rp.background 32, 120, 32
    @rp.stroke *Black
    @rp.fill *Black
    @rp.stroke_width 2
    # 格子
    9.times do |i|
      @rp.line Padding + i * CSize, Padding,
               Padding + i * CSize, Padding + 8 * CSize
      @rp.line Padding, Padding + i * CSize,
               Padding + 8 * CSize, Padding + i * CSize
    end
    # 4つの点
    [[2, 2], [6, 2], [2, 6], [6, 6]].each {|x, y|
      @rp.ellipse Padding + x * CSize, Padding + y * CSize,
                  CSize / 10, CSize / 10
    }
    # 石
    @rp.stroke_width 1
    8.times {|y|
      8.times {|x|
        next if @data[y][x] == 0
        @rp.stroke *(@data[y][x] == 2 ? White : Black)
        @rp.fill *(@data[y][x] == 1 ? White : Black)
        @rp.ellipse Padding + x * CSize + CSize / 2,
                    Padding + y * CSize + CSize / 2,
                    CSize * 16 / 20, CSize * 16 / 20
      }
    }
  end

  # マウス座標をボード座標(0-7)に変換 (はみ出たら強制的に0〜7に)
  def mouse2board(x: 0, y: 0)
    x1 = (x - Padding) / CSize
    y1 = (y - Padding) / CSize
    x1 = 0 if x1 < 0
    y1 = 0 if y1 < 0
    x1 = 7 if x1 > 7
    y1 = 7 if y1 > 7
    return [x1, y1]
  end

  # その色がその場所に置けるかどうか true/false で返す。
  def can_put(x: 0, y: 0, color: :white)
    raise "position out of range" if x < 0 || y < 0 || x > 7 || y > 7
    return false if @data[y][x] != 0
    me = (color == :white) ? 1 : 2
    opp = (color == :white) ? 2 : 1
    putFlag = false
    Dir8.each {|u, v|
      x1, y1 = x, y
      cur = opp
      loop {
        x1 = x1 + u
        y1 = y1 + v
        break if x1 < 0 || x1 > 7 || y1 < 0 || y1 > 7
        break if @data[y1][x1] == 0
        if @data[y1][x1] == me
          putFlag = true if cur == me
          break
        else
          cur = me
        end
      }
    }
    putFlag
  end
end
