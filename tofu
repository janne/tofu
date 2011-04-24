#!/usr/bin/env ruby
require 'optparse'
require 'yaml'
require 'tempfile'

class Tofu
  TODAY = Time.new.strftime("%Y-%m-%d")
  DONE_REGEXP = /^[xX]\s/

  def self.command(command, help = nil, &block)
    @command_help ||= []
    spaces = " " * (10-command.length)
    @command_help << "  #{command}#{spaces}#{help}" if help
    @commands ||= {}
    @commands[command] = block
  end

  def self.items
    @items ||= File.read(@todo_file).split("\n")
  end

  def self.filtered_items
    return @filtered_items if defined?(@filtered_items)
    if @done || @archived
      @filtered_items = (@done ? items.select{|item| item =~ DONE_REGEXP } : []) + (@archived && File.exists?(@archive_file) ? File.read(@archive_file).split("\n") : [])
    else
      @filtered_items = items
    end
  end

  def self.less(lines)
    file = Tempfile.new('tofu')
    begin
      file.write(lines.join("\n"))
      file.close
      pager = ENV['PAGER'] || 'less -P?'
      system("#{pager} #{file.path}")
    ensure
      file.unlink
    end
  end

  command 'add', 'Create todo, text from args or STDIN, one per line' do |args|
    texts = args.empty? ? $stdin.read.split("\n") : [args.join(' ')]
    texts.each do |text|
      length = items.length
      if @archived
        File.open(@archive_file, 'a') do |f|
          f.printf("x %s %s\n", TODAY, text)
          printf("Added 'x %s %s' to archive\n", TODAY, text)
        end
      elsif @done
        File.open(@todo_file, 'a') do |f|
          f.printf("x %s %s\n", TODAY, text)
          printf("Added '%s' to line %i and marked as done\n", text, length + 1)
        end
      else
        File.open(@todo_file, 'a') do |f|
          f.printf("%s\n", text)
          printf("Added '%s' to line %i\n", text, length + 1)
        end
      end
    end
  end

  command 'archive', 'Archive all done items and sort remaining items' do
    archived = 0
    File.open(@archive_file, 'a') do |f|
      items.select{|item| item =~ DONE_REGEXP }.each do |item|
        if (m = item.match(/^[xX]\s+(\d{4}-\d{2}-\d{2})\s(.*)$/))
          f.printf("x %s\n", item[2..-1])
        else
          f.printf("x %s %s\n", TODAY, item[2..-1])
        end
        archived += 1
      end
    end
    File.open(@todo_file + '.tmp', 'w') do |f|
      f.printf("%s\n", items.reject{|item| item =~ DONE_REGEXP }.sort.join("\n"))
    end
    `mv #{@todo_file + '.tmp'} #{@todo_file}`
    puts "Archived #{archived} item#{'s' unless archived == 1}"
  end

  command 'do', 'Remove todo, add to done, row numbers from args' do |args|
    nums = args.map(&:to_i)
    if nums.empty? || nums.any?{|num| num <= 0 || num > items.length || items[num-1] =~ DONE_REGEXP }
      puts "Missing or invalid line numbers"
      exit 1
    end
    File.open(@todo_file + '.tmp', 'w') do |f|
      items.each_with_index do |item, i|
        if nums.include?(i+1)
          f.printf("x #{TODAY} %s\n", item)
          puts "Marked '#{item}' as done"
        else
          f.printf("%s\n", item)
        end
      end
      `mv #{@todo_file + '.tmp'} #{@todo_file}`
    end
  end

  command 'edit', 'Open file in editor' do
    editor = ENV['EDITOR'] || 'vim'
    exec "#{editor} #{@archived ? @archive_file : @todo_file}"
  end

  command 'count', 'Count words beginning with prefixes from args' do |args|
    if args.empty?
      puts "Missing prefix"
      exit 1
    end
    hash = {}
    filtered_items.join(' ').split("\s").map(&:strip).select{|s| s.length > 1 && args.any?{|p| s.index(p) == 0 } }.each do |s|
      hash[s] ? hash[s] += 1 : hash[s] = 1
    end
    hash.to_a.sort{|a,b| order = -(a[1] <=> b[1]); order == 0 ? a[0] <=> b[0] : order }.each do |k, v|
      puts "#{k}: #{v}"
    end
  end

  command 'list' do
    filters = ARGV
    row_items = (1..filtered_items.length).to_a.zip(filtered_items)
    row_items = row_items.reject{|row, item| item =~ DONE_REGEXP} unless @done || @archived
    unless filters.empty?
      row_items = row_items.select{|row, item| filters.all?{|filter| item.include?(filter)}}
    end
    if row_items.empty?
      puts "Nothing found"
    else
      lines = row_items.sort{|a, b| a[1] <=> b[1] }.map{|row, item| @done || @archived ? item : sprintf("%*i %s", filtered_items.length.to_s.length, row, item) }
      if lines.length > `tput lines`.to_i then less(lines) else puts lines end
    end
  end

  def self.option_parser
    OptionParser.new do |opts|
      opts.banner = <<EOF
Very simple todo CLI app

Usage
  #{File.basename($0)} [options] [filters...]
  #{File.basename($0)} [options] command [args...]

Options
EOF
      opts.on('-a', '--archived', 'affect archived items') { @archived = true }
      opts.on('-d', '--done', 'affect done items') { @done = true }
      opts.on('-f', '--file FILE', 'Specify todo file') { |f| @todo_file = f }
      opts.on('-h', '--help', 'Display this help') { puts opts; exit }
      opts.separator ""
      opts.separator "Commands"
      @command_help.sort.each{|h| opts.separator h }
      opts.separator ""
      opts.separator "List items without command, filter on args"
    end
  end

  def self.run
    if rc = ["./.tofuconfig", "~/.tofuconfig"].map{|f| File.expand_path(f)}.detect{|f| File.exists?(f)}
      settings = YAML.load(File.read(rc))
      @todo_file = File.expand_path(settings['todo_file']) if settings['todo_file']
      @archive_file = File.expand_path(settings['archive_file']) if settings['archive_file']
    end
    @done = @archived = false
    opts = option_parser
    opts.parse!
    @todo_file = File.expand_path("~/todo.txt") unless defined?(@todo_file)
    @archive_file = File.dirname(@todo_file) + "/archive." + File.basename(@todo_file) unless defined?(@archive_file)
    if File.exists?(@todo_file)
      if (@commands.has_key?(ARGV[0]))
        @commands[ARGV[0]].call(ARGV[1..-1])
      else
        @commands['list'].call
      end
    else
      puts "No such file exists '#{@todo_file}'. You may create it with 'touch #{@todo_file}'"
      puts(opts)
    end
  end
end
Tofu.run
