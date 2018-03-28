require 'rmagick'

class PlotDataPool
  attr_accessor :pool, :avg

  def initialize(data_dir = './data')
    @pool = []
    Dir.foreach(data_dir) do |f|
      next if f == "." || f == ".."
      @pool << PlotData.new(data_dir + '/' + f)
    end

    rects = @pool.map(&:rects)
    @avg = {}
    @avg[:head] = {x1: rects.map {|rect| rect[:head][:x1]}.inject(:+) / rects.size, y1: rects.map {|rect| rect[:head][:y1]}.inject(:+) / rects.size, x2: rects.map {|rect| rect[:head][:x2]}.inject(:+) / rects.size, y2: rects.map {|rect| rect[:head][:y2]}.inject(:+) / rects.size}
    @avg[:mayu] = {x1: rects.map {|rect| rect[:mayu][:x1]}.inject(:+) / rects.size, y1: rects.map {|rect| rect[:mayu][:y1]}.inject(:+) / rects.size, x2: rects.map {|rect| rect[:mayu][:x2]}.inject(:+) / rects.size, y2: rects.map {|rect| rect[:mayu][:y2]}.inject(:+) / rects.size}
    @avg[:eye] = {x1: rects.map {|rect| rect[:eye][:x1]}.inject(:+) / rects.size, y1: rects.map {|rect| rect[:eye][:y1]}.inject(:+) / rects.size, x2: rects.map {|rect| rect[:eye][:x2]}.inject(:+) / rects.size, y2: rects.map {|rect| rect[:eye][:y2]}.inject(:+) / rects.size}
    @avg[:iris] = {x1: rects.map {|rect| rect[:iris][:x1]}.inject(:+) / rects.size, y1: rects.map {|rect| rect[:iris][:y1]}.inject(:+) / rects.size, x2: rects.map {|rect| rect[:iris][:x2]}.inject(:+) / rects.size, y2: rects.map {|rect| rect[:iris][:y2]}.inject(:+) / rects.size}
    @avg[:nose] = {x1: rects.map {|rect| rect[:nose][:x1]}.inject(:+) / rects.size, y1: rects.map {|rect| rect[:nose][:y1]}.inject(:+) / rects.size, x2: rects.map {|rect| rect[:nose][:x2]}.inject(:+) / rects.size, y2: rects.map {|rect| rect[:nose][:y2]}.inject(:+) / rects.size}
    @avg[:mouth] = {x1: rects.map {|rect| rect[:mouth][:x1]}.inject(:+) / rects.size, y1: rects.map {|rect| rect[:mouth][:y1]}.inject(:+) / rects.size, x2: rects.map {|rect| rect[:mouth][:x2]}.inject(:+) / rects.size, y2: rects.map {|rect| rect[:mouth][:y2]}.inject(:+) / rects.size}
    @avg[:cheak] = {x1: rects.map {|rect| rect[:cheak][:x1]}.inject(:+) / rects.size, y1: rects.map {|rect| rect[:cheak][:y1]}.inject(:+) / rects.size, x2: rects.map {|rect| rect[:cheak][:x2]}.inject(:+) / rects.size, y2: rects.map {|rect| rect[:cheak][:y2]}.inject(:+) / rects.size}
    @avg[:uwamabuta0] = {x1: rects.map {|rect| rect[:uwamabuta0][:x1]}.inject(:+) / rects.size, y1: rects.map {|rect| rect[:uwamabuta0][:y1]}.inject(:+) / rects.size, x2: rects.map {|rect| rect[:uwamabuta0][:x2]}.inject(:+) / rects.size, y2: rects.map {|rect| rect[:uwamabuta0][:y2]}.inject(:+) / rects.size}
    @avg[:uwamabuta1] = {x1: rects.map {|rect| rect[:uwamabuta1][:x1]}.inject(:+) / rects.size, y1: rects.map {|rect| rect[:uwamabuta1][:y1]}.inject(:+) / rects.size, x2: rects.map {|rect| rect[:uwamabuta1][:x2]}.inject(:+) / rects.size, y2: rects.map {|rect| rect[:uwamabuta1][:y2]}.inject(:+) / rects.size}
    @avg[:uwamabuta2] = {x1: rects.map {|rect| rect[:uwamabuta2][:x1]}.inject(:+) / rects.size, y1: rects.map {|rect| rect[:uwamabuta2][:y1]}.inject(:+) / rects.size, x2: rects.map {|rect| rect[:uwamabuta2][:x2]}.inject(:+) / rects.size, y2: rects.map {|rect| rect[:uwamabuta2][:y2]}.inject(:+) / rects.size}
    @avg[:iris_center] = {x1: rects.map {|rect| rect[:iris_center][:x1]}.inject(:+) / rects.size, y1: rects.map {|rect| rect[:iris_center][:y1]}.inject(:+) / rects.size, x2: rects.map {|rect| rect[:iris_center][:x2]}.inject(:+) / rects.size, y2: rects.map {|rect| rect[:iris_center][:y2]}.inject(:+) / rects.size}
  end

  def plot_all(gc, stroke_strength = 1.0)
    @pool.each do |data|
      PlotData.plot(gc, data.rects, stroke_strength)
    end
  end

  def plot_avg(gc, stroke_strength = 1.0)
    PlotData.plot(gc, @avg, stroke_strength)
  end

  def generate(width, height, mode, mirror = false, stroke_strength = 1.0, resize = 1.0)
    image_list = Magick::ImageList.new

    img = Magick::Image.new(width, height)
    img.alpha(Magick::ActivateAlphaChannel)
    gc = Magick::Draw.new
    gc.fill('none')
    gc.fill_opacity(0)

    case mode
      when :all then
        plot_all(gc, stroke_strength)
      when :avg then
        plot_avg(gc, stroke_strength)
      else
        fail
    end
    gc.draw(img)

    image_list << img.flop if mirror
    image_list << img
    image_list = image_list.append(false)
    image_list = image_list.resize(resize)
    image_list.write("./out/plot_#{mode}.png")
  end
end

class PlotData
  attr_accessor :rects

  def initialize(file_path)
    @rects = {}

    File.open(file_path, 'r:utf-8') do |file|
      file.gets
      s = file.gets.split("\t")
      @rects[:head] = {x1: s[0].to_i, y1: s[1].to_i, x2: s[6].to_i, y2: s[7].to_i}
      s = file.gets.split("\t")
      @rects[:mayu] = {x1: s[0].to_i, y1: s[1].to_i, x2: s[6].to_i, y2: s[7].to_i}
      s = file.gets.split("\t")
      @rects[:eye] = {x1: s[0].to_i, y1: s[1].to_i, x2: s[6].to_i, y2: s[7].to_i}
      s = file.gets.split("\t")
      @rects[:iris] = {x1: s[0].to_i, y1: s[1].to_i, x2: s[6].to_i, y2: s[7].to_i}
      s = file.gets.split("\t")
      @rects[:nose] = {x1: s[0].to_i, y1: s[1].to_i, x2: s[6].to_i, y2: s[7].to_i}
      s = file.gets.split("\t")
      @rects[:mouth] = {x1: s[0].to_i, y1: s[1].to_i, x2: s[6].to_i, y2: s[7].to_i}
      s = file.gets.split("\t")
      @rects[:cheak] = {x1: s[0].to_i, y1: s[1].to_i, x2: s[0].to_i + 1, y2: s[1].to_i + 1}
      s = file.gets.split("\t")
      @rects[:uwamabuta0] = {x1: s[0].to_i, y1: s[1].to_i, x2: s[0].to_i + 1, y2: s[1].to_i + 1}
      s = file.gets.split("\t")
      @rects[:uwamabuta1] = {x1: s[0].to_i, y1: s[1].to_i, x2: s[0].to_i + 1, y2: s[1].to_i + 1}
      s = file.gets.split("\t")
      @rects[:uwamabuta2] = {x1: s[0].to_i, y1: s[1].to_i, x2: s[0].to_i + 1, y2: s[1].to_i + 1}
      @rects[:iris_center] = {x1: (@rects[:iris][:x2] + @rects[:iris][:x1]) / 2.0, y1: (@rects[:iris][:y2] + @rects[:iris][:y1]) / 2.0, x2: 1, y2: 1}
    end
  end

  def self.plot(gc, dict, stroke_strength = 1.0)
    # default
    gc.stroke('red')
    gc.stroke_width(1 * stroke_strength)

    # red
    gc.stroke('red')
    rect = dict[:head]
    gc.rectangle(rect[:x1], rect[:y1], rect[:x2], rect[:y2])
    gc.ellipse(0, rect[:y2] / 1.9, rect[:x2], rect[:y2] - rect[:y2] / 1.9, 0, 180)
    gc.ellipse(0, rect[:y2] / 3.0, rect[:x2], rect[:y2] / 3.0, 180, 360)

    # rect = dict[:eye]
    # gc.rectangle(rect[:x1], rect[:y1], rect[:x2], rect[:y2])

    rect = dict[:iris]
    gc.ellipse(dict[:iris_center][:x1], dict[:iris_center][:y1], (rect[:x2] - rect[:x1]) / 2.0, (rect[:y2] - rect[:y1]) / 2.0, 0, 360)
    gc.line(rect[:x1], rect[:y2], rect[:x2], rect[:y2])
    gc.ellipse(dict[:iris][:x2], dict[:uwamabuta2][:y1], dict[:uwamabuta2][:x1] - dict[:iris][:x2], dict[:iris][:y2] - dict[:uwamabuta2][:y1], 0, 90)
    gc.ellipse(dict[:iris][:x1], dict[:uwamabuta0][:y1], dict[:iris][:x1] - dict[:uwamabuta0][:x1], dict[:iris][:y2] - dict[:uwamabuta0][:y1], 90, 180)

    rect = dict[:mouth]
    # gc.rectangle(rect[:x1], rect[:y1], rect[:x2], rect[:y2])
    gc.ellipse(0, rect[:y1], rect[:x2] - rect[:x1], rect[:y2] - rect[:y1], 0, 180)

    # orange
    gc.stroke('orange')
    rect = dict[:mayu]
    gc.ellipse(rect[:x2], rect[:y2], rect[:x2] - rect[:x1], rect[:y2] - rect[:y1], 180, 270)

    # green
    gc.stroke('green')
    gc.stroke_width(3 * stroke_strength)

    rect = dict[:cheak]
    gc.rectangle(rect[:x1], rect[:y1], rect[:x2], rect[:y2])

    rect = dict[:nose]
    gc.line(0, rect[:y2], rect[:x2], rect[:y2])
    gc.line(0, rect[:y1], rect[:x2], rect[:y2])

    gc.stroke('blue')
    gc.stroke_width(3 * stroke_strength)

    # gc.line(dict[:uwamabuta0][:x1], dict[:uwamabuta0][:y1], dict[:uwamabuta1][:x1], dict[:uwamabuta1][:y1])
    gc.ellipse(dict[:uwamabuta1][:x1], dict[:uwamabuta2][:y1], dict[:uwamabuta1][:x1] - dict[:uwamabuta0][:x1], dict[:uwamabuta0][:y1] - dict[:uwamabuta1][:y1], 180, 270)
    gc.ellipse(dict[:uwamabuta1][:x1], dict[:uwamabuta2][:y1], dict[:uwamabuta2][:x1] - dict[:uwamabuta1][:x1], dict[:uwamabuta2][:y1] - dict[:uwamabuta1][:y1], 270, 360)
    gc.ellipse(dict[:iris][:x2], dict[:uwamabuta2][:y1], dict[:uwamabuta2][:x1] - dict[:iris][:x2], dict[:iris][:y2] - dict[:uwamabuta2][:y1], 0, 40)
  end
end

pool = PlotDataPool.new
pool.generate(500, 1000, :all, mirror = true, stroke_strength = 0.01, resize = 0.25)
pool.generate(500, 1000, :avg, mirror = true, stroke_strength = 3.0, resize = 0.25)

# composite
base = Magick::Image.read('./out/plot_all.png').first
append = Magick::Image.read('./out/plot_avg.png').first
mix = base.composite(append, 0, 0, Magick::MultiplyCompositeOp)
mix.write("./out/plot_mix.png")