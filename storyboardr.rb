require 'sinatra/base'
require 'fastercsv'
require 'lib/extensions'

$: << File.expand_path('lib/prawn-edge/lib', File.dirname(__FILE__))
require 'prawn'

class Storyboardr < Sinatra::Base
  
  COLORS = %w(
    FCD600
    1E7114
    FF620C
    FC000E
    0A0BFF
    B717E8
    544B5C
    C8477F
  )
  
  get '/' do
    erb :index
  end
  
  post '/' do
    filename = params[:file][:filename]
    file = params[:file][:tempfile]
    
    line = 0
    data = FasterCSV.parse(file)
    stories = data.collect do |project, type, description, estimate|
       {
        :line         => (line += 1),
        :project      => project.to_s,
        :type         => type.to_s,
        :description  => description.to_s,
        :estimate     => estimate.to_s
      }
    end
    
    stories.shift # removing first item as it's labels
    stories = stories.reject{|s| s[:description] == '' } 
    
    @pdf = Prawn::Document.new( :margin => 12 )
    
    table = []
    stories.in_groups_of(2, false) do |stories_line|
      row = []
      stories_line.each do |story|
        row << [
          [ Prawn::Table::Cell.make(@pdf, rendered_story(story), 
              :width            => 294, 
              :border_color     => 'ffffff', 
              :background_color => 'eeeeee') ],
          [ Prawn::Table::Cell.make(@pdf, story[:description], 
              :height       => 100, 
              :width        => 294, 
              :border_color => 'cccccc', 
              :font_size    => 10, 
              :text_color   => '666666') ],
          [ Prawn::Table::Cell.make(@pdf, rendered_footer,
              :width        => 294, 
              :border_color => 'ffffff') ]
        ]
      end
      table << row 
    end
    
    @pdf.table( table, :cell_style => { :border_color => 'ffffff' } )
    
    content_type 'application/pdf'
    attachment 'test.pdf'
    @pdf.render
  end
  
protected

  def rendered_story(story)
    
    @old_project = @project
    @project = story[:project]
    @color_index ||= 0
    @color_index += 1 if @old_project != @project
    color = COLORS[@color_index]
    @color_index = 0 if COLORS[@color_index].nil?
    
    [[  Prawn::Table::Cell.make(@pdf, "##{story[:line]}",
          :width            => 35, 
          :border_color     => 'cccccc', 
          :font_size        => 11,
          :background_color => color,
          :text_color       => 'ffffff'),
        Prawn::Table::Cell.make(@pdf, [story[:project], story[:type]].join(' - '),
          :width        => 224, 
          :border_color => 'cccccc', 
          :font_size    => 11, 
          :font_style   => :bold),
        Prawn::Table::Cell.make(@pdf, story[:estimate],
          :width        => 35, 
          :border_color => 'cccccc', 
          :font_size    => 11)
    ]]
  end
  
  def rendered_footer
    [[
      Prawn::Table::Cell.make(@pdf, '', :width => 73, :height => 30, :border_color => 'cccccc'),
      Prawn::Table::Cell.make(@pdf, '', :width => 73, :height => 30, :border_color => 'cccccc'),
      Prawn::Table::Cell.make(@pdf, '', :width => 74, :height => 30, :border_color => 'cccccc'),
      Prawn::Table::Cell.make(@pdf, '', :width => 74, :height => 30, :border_color => 'cccccc')
    ]]
  end
  
end