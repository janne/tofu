#!/usr/bin/env ruby
require 'optparse'
require 'yaml'

class Tofu
  def self.command(command, help = nil, &block)
    @command_help ||= []
    @command_help << "  #{command}\t\t#{help}" if help
    @commands ||= {}
    @commands[command] = block
  end

  command 'add', 'Create todo, text from args or STDIN, one per line' do |args|
    texts = args.empty? ? $stdin.read.split("\n") : [args.join(' ')]
    texts.each do |text|
      length = File.read(@file).split("\n").length
      File.open(@file, 'a') do |f|
        printf(f, "%s\n", text)
        printf("Added '%s' to line %i\n", text, length + 1)
      end
    end
  end

  command 'do', 'Remove line from todo, add to done, row numbers from args' do |args|
    lines = File.read(@file).split("\n")
    nums = args.map(&:to_i)
    if nums.empty? || nums.any?{|num| num <= 0 || num > lines.length}
      puts "Missing or invalid line numbers"
      exit 1
    end
    File.open(File.dirname(@file) + "/done." + File.basename(@file), 'a') do |f|
      nums.each do |num|
        text = lines[num-1]
        printf(f, "x #{Time.new.strftime("%Y-%m-%d")} #{text}\n")
        puts "Marked '#{text}' as done"
      end
    end
    File.open(@file + '.tmp', 'w') do |f|
      lines.each_with_index do |line, i|
        unless nums.include?(i+1)
          f.printf("%s\n", line)
        end
      end
      `mv #{@file + '.tmp'} #{@file}`
    end
  end

  command 'edit', 'Open file in editor' do
    editor = ENV['EDITOR'] || 'vim'
    exec "#{editor} #{@file}"
  end

  command 'count', 'Count words beginning with prefixes from args' do |args|
    if args.empty?
      puts "Missing prefix"
      exit 1
    end
    hash = {}
    File.read(@file).split("\s").map(&:strip).select{|s| s.length > 1 && args.any?{|p| s.index(p) == 0 } }.each do |s|
      hash[s] ? hash[s] += 1 : hash[s] = 1
    end
    hash.to_a.sort{|a,b| order = -(a[1] <=> b[1]); order == 0 ? a[0] <=> b[0] : order }.each do |k, v|
      puts "#{k}: #{v}"
    end
  end

  command 'list' do
    filters = ARGV
    lines = File.read(@file).split("\n")
    length = lines.length
    lines = (1..lines.length).to_a.zip(lines)
    unless filters.empty?
      lines = lines.select{|i, line| filters.all?{|filter| line.include?(filter)}} 
      puts "Nothing found" if lines.empty?
    end
    lines.sort{|a, b| a[1] <=> b[1] }.each{|i, text| printf("%*i %s\n", length.to_s.length, i, text) }
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
      opts.on('-f', '--file FILE', 'Specify todo file') do |f|
        @file = f
      end
      opts.on('-h', '--help', 'Display this help') do
        puts opts
        exit
      end

      opts.separator ""
      opts.separator "Commands"
      @command_help.each{|h| opts.separator h }
      opts.separator ""
      opts.separator "List items without command, filter on args"
    end
  end

  def self.run
    if rc = ["./.tofurc", "~/.tofurc"].map{|f| File.expand_path(f)}.detect{|f| File.exists?(f)}
      @file = File.expand_path(YAML.load(File.read(rc))['file'])
    else
      @file = File.expand_path("~/todo.txt")
    end
    opts = option_parser
    opts.parse!
    if File.exists?(@file)
      if (@commands.has_key?(ARGV[0]))
        @commands[ARGV[0]].call(ARGV[1..-1])
      else
        @commands['list'].call
      end
    else
      puts "No such file exists '#{@file}'. You may create it with 'touch #{@file}'"
      puts(opts)
    end
  end
end
Tofu.run
