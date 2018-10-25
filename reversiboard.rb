# coding: utf-8

class ReversiBoard
  private
  @rp                      # ruby processing Sketch のインスタンス
  CSize = 80               # 1マスのサイズ (pixel)
  Padding = 16             # ゲーム盤上下左右の余白
  Black = [0, 0, 0]        # 黒石の色
  White = [255, 255, 255]  # 白石の色
  Dir8 = [[1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1], [0, 1], [1, 1]]
  @frames                  # アニメーション表示ようの配列。先頭は @data。

  public
  # @!attribute data [rw]
  #   @return [Integer] 8x8 の配列で 0=空, 1=白, 2 =黒 として状態を保存. 行(y), 列(x)の順
  # @!attribute smooth_animation [rw]
  #   @return [Boolean] #put メソッドで石を置いたときに反転が段階的に表示されるか
  attr_accessor :data
  attr_accessor :smooth_animation


  # x, y 座標に石を配置. color は :black もしくは :white
  # @param x [Integer] x 座標 (0-7)
  # @param y [Integer] y 座標 (0-7)
  # @param color [Symbol] 色 (:white か :black)
  # @param  autoflip [Boolean] 置いたら自動でひっくり返すか
  def put(x: 0, y: 0, color: :white, autoflip: true)
    raise "position out of range" if x < 0 || y < 0 || x > 7 || y > 7
    @frames.insert 1, @data.map {|i| i.map{|j| j}}
    case color
    when :black
      @data[y][x] = 2
    when :white
      @data[y][x] = 1
    end
    me = (color == :white) ? 1 : 2
    opp = (color == :white) ? 2 : 1
    if autoflip
      Dir8.each {|u, v|
        x1, y1 = x, y
        cur = opp
        loop {
          x1 = x1 + u
          y1 = y1 + v
          break if x1 < 0 || x1 > 7 || y1 < 0 || y1 > 7
          break if @data[y1][x1] == 0
          if @data[y1][x1] == me
            if cur == me
              x1, y1 = x + u, y + v
              while @data[y1][x1] == opp
                @frames.insert 1, @data.map {|i| i.map{|j| j}} if smooth_animation
                @data[y1][x1] = me
                x1 = x1 + u
                y1 = y1 + v
              end
              break
            else
              break
            end
          else
            cur = me
          end
        }
      }
    end
  end

  # @param sketch [Sketch] ruby-processing のスケッチ. 通常 self を渡せば ok
  def initialize(sketch)
    @smooth_animation = true
    @rp = sketch
    @rp.size CSize * 8 + Padding * 2, CSize * 8 + Padding * 2
    @data = Array.new(8).map {Array.new(8).map {0}}
    @frames = [@data]
    put(x: 3, y: 3, color: :white)
    put(x: 4, y: 4, color: :white)
    put(x: 3, y: 4, color: :black)
    put(x: 4, y: 3, color: :black)
  end

  # ゲーム盤表示 (ruby-processing スケッチの draw から呼び出す)
  # @return [nil]
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
        next if @frames[-1][y][x] == 0
        @rp.stroke *(@frames[-1][y][x] == 2 ? White : Black)
        @rp.fill *(@frames[-1][y][x] == 1 ? White : Black)
        @rp.ellipse Padding + x * CSize + CSize / 2,
                    Padding + y * CSize + CSize / 2,
                    CSize * 16 / 20, CSize * 16 / 20
      }
    }
    @frames.pop if @frames.length > 1
    nil
  end

  # マウス座標をボード座標(0-7)に変換 (はみ出たら強制的に0〜7に)
  # @param x [Integer] マウスの x 座標
  # @param y [Integer] マウスの y 座標
  # @return [Array] ボードの [x, y] 座標 (0-7)
  def mouse2board(x: 0, y: 0)
    x1 = (x - Padding) / CSize
    y1 = (y - Padding) / CSize
    x1 = 0 if x1 < 0
    y1 = 0 if y1 < 0
    x1 = 7 if x1 > 7
    y1 = 7 if y1 > 7
    return [x1, y1]
  end

  # その色がその場所に置けるかどうか
  # @param x [Integer] x 座標 (0-7)
  # @param y [Integer] y 座標 (0-7)
  # @param color [Symbol] :white か :black
  # @return [Boolean]
  def can_put?(x: 0, y: 0, color: :white)
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

  # 石の数を数える
  # @param color [Symbol] :white か :black
  # @return [Integer]
  def count(color: :white)
    tgt = (color == :white) ? 1 : 2
    @data.inject(0) {|acc, row|
      acc + row.inject(0) {|a, x|
        a + ((x == tgt) ? 1 : 0)
      }
    }
  end

  # 置ける場所を探す
  # @param color [Symbol] :white か :black
  # @return [Array] [x, y] の座標 (2要素配列) の配列
  def find_places(color: :white)
    ret = []
    8.times {|y|
      8.times {|x|
        ret.push [x, y] if can_put?(x: x, y: y, color: color)
      }
    }
    ret
  end
end
