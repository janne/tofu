#!/usr/bin/env ruby
require 'optparse'
require 'yaml'

class Tofu
  def self.command(command, help = nil, &block)
    @command_help ||= []
    spaces = " " * (10-command.length)
    @command_help << "  #{command}#{spaces}#{help}" if help
    @commands ||= {}
    @commands[command] = block
  end

  def self.file
    @@file
  end

  def self.items
    @@items ||= File.read(file).split("\n")
  end

  def self.done_file
    File.dirname(file) + "/done." + File.basename(file)
  end

  def self.done_regexp
    /^[xX]\s/
  end

  command 'add', 'Create todo, text from args or STDIN, one per line' do |args|
    texts = args.empty? ? $stdin.read.split("\n") : [args.join(' ')]
    texts.each do |text|
      length = items.length
      File.open(file, 'a') do |f|
        printf(f, "%s\n", text)
        printf("Added '%s' to line %i\n", text, length + 1)
      end
    end
  end

  command 'archive', 'Archive all done items and sort remaining items' do
    archived = 0
    File.open(done_file, 'a') do |f|
      items.select{|item| item =~ done_regexp }.each do |item|
        f.printf("%s\n", item)
        archived += 1
      end
    end
    File.open(file + '.tmp', 'w') do |f|
      f.printf("%s\n", items.reject{|item| item =~ done_regexp }.sort.join("\n"))
    end
    `mv #{file + '.tmp'} #{file}`
    puts "Archived #{archived} item#{'s' unless archived == 1}"
  end

  command 'do', 'Remove todo, add to done, row numbers from args' do |args|
    nums = args.map(&:to_i)
    if nums.empty? || nums.any?{|num| num <= 0 || num > items.length || items[num-1] =~ done_regexp }
      puts "Missing or invalid line numbers"
      exit 1
    end
    File.open(file + '.tmp', 'w') do |f|
      items.each_with_index do |item, i|
        if nums.include?(i+1)
          f.printf("x #{Time.new.strftime("%Y-%m-%d")} %s\n", item)
          puts "Marked '#{item}' as done"
        else
          f.printf("%s\n", item)
        end
      end
      `mv #{file + '.tmp'} #{file}`
    end
  end

  command 'done', 'List done items, both archived and unarchived' do
    done_items = items.select{|item| item =~ done_regexp } + File.read(done_file).split("\n")
    if done_items.empty?
      puts "Nothing found"
    else
      puts done_items.sort
    end
  end

  command 'edit', 'Open file in editor' do
    editor = ENV['EDITOR'] || 'vim'
    exec "#{editor} #{file}"
  end

  command 'count', 'Count words beginning with prefixes from args' do |args|
    if args.empty?
      puts "Missing prefix"
      exit 1
    end
    hash = {}
    File.read(file).split("\s").map(&:strip).select{|s| s.length > 1 && args.any?{|p| s.index(p) == 0 } }.each do |s|
      hash[s] ? hash[s] += 1 : hash[s] = 1
    end
    hash.to_a.sort{|a,b| order = -(a[1] <=> b[1]); order == 0 ? a[0] <=> b[0] : order }.each do |k, v|
      puts "#{k}: #{v}"
    end
  end

  command 'list' do
    filters = ARGV
    row_items = (1..items.length).to_a.zip(items)
    row_items = row_items.reject{|row, item| item =~ done_regexp}
    unless filters.empty?
      row_items = row_items.select{|row, item| filters.all?{|filter| item.include?(filter)}}
      puts "Nothing found" if row_items.empty?
    end
    row_items.sort{|a, b| a[1] <=> b[1] }.each{|row, item| printf("%*i %s\n", items.length.to_s.length, row, item) }
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
        @@file = f
      end
      opts.on('-h', '--help', 'Display this help') do
        puts opts
        exit
      end

      opts.separator ""
      opts.separator "Commands"
      @command_help.sort.each{|h| opts.separator h }
      opts.separator ""
      opts.separator "List items without command, filter on args"
    end
  end

  def self.run
    if rc = ["./.tofurc", "~/.tofurc"].map{|f| File.expand_path(f)}.detect{|f| File.exists?(f)}
      @@file = File.expand_path(YAML.load(File.read(rc))['file'])
    else
      @@file = File.expand_path("~/todo.txt")
    end
    opts = option_parser
    opts.parse!
    if File.exists?(file)
      if (@commands.has_key?(ARGV[0]))
        @commands[ARGV[0]].call(ARGV[1..-1])
      else
        @commands['list'].call
      end
    else
      puts "No such file exists '#{file}'. You may create it with 'touch #{file}'"
      puts(opts)
    end
  end
end
Tofu.run
