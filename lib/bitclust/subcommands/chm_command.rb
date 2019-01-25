# -*- coding: utf-8 -*-

require 'bitclust'
require 'bitclust/subcommand'

require 'fileutils'
# TODO Remove this line when we drop 1.8 support
require 'kconv'
require 'bitclust/progress_bar'

module BitClust
  module Subcommands
    class ChmCommand < Subcommand

      HHP_SKEL = <<EOS
[OPTIONS]
Compatibility=1.1 or later
Compiled file=refm.chm
Contents file=refm.hhc
Default Window=titlewindow
Default topic=doc/index.html
Display compile progress=No
Error log file=refm.log
Full-text search=Yes
Index file=refm.hhk
Language=0x411 日本語 (日本)
Title=Rubyリファレンスマニュアル

[WINDOWS]
titlewindow="Rubyリファレンスマニュアル","refm.hhc","refm.hhk","doc/index.html","doc/index.html",,,,,0x21420,,0x387e,,,,,,,,0

[FILES]
<%= @html_files.join("\n") %>
EOS

      HHC_SKEL = <<EOS
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="text/html; charset=Windows-31J">
</HEAD>
<BODY>
<UL>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="はじめに">
        <param name="Local" value="doc/spec=2fintro.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="コマンド">
        <param name="Local" value="doc/spec=2fcommands.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="Rubyの起動">
        <param name="Local" value="doc/spec=2frubycmd.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="環境変数">
        <param name="Local" value="doc/spec=2fenvvars.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="Ruby言語仕様">
        </OBJECT>
<UL>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="Ruby でのオブジェクト">
        </OBJECT>
<UL>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="オブジェクト">
        <param name="Local" value="doc/spec=2fobject.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="クラス">
        <param name="Local" value="doc/spec=2fclass.html">
        </OBJECT>
</UL>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="プロセスの実行">
        </OBJECT>
<UL>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="Ruby プログラムの実行">
        <param name="Local" value="doc/spec=2feval.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="終了処理">
        <param name="Local" value="doc/spec=2fterminate.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="スレッド">
        <param name="Local" value="doc/spec=2fthread.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="セキュリティモデル">
        <param name="Local" value="doc/spec=2fsafelevel.html">
        </OBJECT>
</UL>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="Ruby の文法">
        </OBJECT>
<UL>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="字句構造">
        <param name="Local" value="doc/spec=2flexical.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="プログラム・文・式">
        <param name="Local" value="doc/spec=2fprogram.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="変数と定数">
        <param name="Local" value="doc/spec=2fvariables.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="リテラル">
        <param name="Local" value="doc/spec=2fliteral.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="演算子式">
        <param name="Local" value="doc/spec=2foperator.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="制御構造">
        <param name="Local" value="doc/spec=2fcontrol.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="メソッド呼び出し(super・ブロック付き・yield)">
        <param name="Local" value="doc/spec=2fcall.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="クラス／メソッドの定義">
        <param name="Local" value="doc/spec=2fdef.html">
        </OBJECT>
</UL>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="多言語化">
        <param name="Local" value="doc/spec=2fm17n.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="正規表現">
        <param name="Local" value="doc/spec=2fregexp.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="手続きオブジェクトの挙動の詳細">
        <param name="Local" value="doc/spec=2flambda_proc.html">
        </OBJECT>
</UL>
</UL>
<!-- library -->
<UL>
<% [:library].each do |k| %>
<%= @sitemap[k].contents.first.to_html %>
<%= @sitemap[k].contents.last.to_html %>
<% end %>
<!-- library end -->
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="Ruby変更履歴">
        <param name="Local" value="doc/news=2findex.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="pack テンプレート文字列">
        <param name="Local" value="doc/pack_template.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="sprintf フォーマット">
        <param name="Local" value="doc/print_format.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="Ruby用語集">
        <param name="Local" value="doc/glossary.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="Rubyで使われる記号の意味">
        <param name="Local" value="doc/symref.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="Marshal フォーマット">
        <param name="Local" value="doc/marshal_format.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="配布条件">
        <param name="Local" value="doc/license.html">
        </OBJECT>
<LI> <OBJECT type="text/sitemap">
        <param name="Name" value="このマニュアルのヘルプ">
        <param name="Local" value="doc/help.html">
        </OBJECT>
</UL>
</BODY>
</HTML>
EOS

      HHK_SKEL = <<EOS
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<meta http-equiv="Content-Type" content="text/html; charset=Windows-31J">
<HEAD>
</HEAD>
<BODY>
<UL><% @index_contents.sort.each do |content| %>
<%= content.to_html %>
<% end %></UL>
</BODY>
</HTML>
EOS

      class Sitemap
        def initialize(name, local = nil)
          @name = name
          @contents = Content.new(name, local)
        end

        def method_missing(name, *args, &block)
          @contents.send(name, *args, &block)
        end

        class Content
          include Enumerable
          include ERB::Util

          def initialize(name, local = nil)
            @name = name
            @local = local
            @contents = []
          end
          attr_reader :name, :local, :contents

          def [](index)
            @contents[index]
          end

          def <<(content)
            @contents << content
          end

          def <=>(other)
            @name <=> other.name
          end

          def each
            @contents.each do |content|
              yield content
            end
          end

          def to_html
            str = "<LI> <OBJECT type=\"text/sitemap\">\n"
            str << "        <param name=\"Name\" value=\"<%=h @name%>\">\n"
            if @local
              str << "        <param name=\"Local\" value=\"<%=@local%>\">\n"
            end
            str << "        </OBJECT>\n"
            unless contents.empty?
              str << "<UL>\n"
              @contents.each do |content|
                str << content.to_html
              end
              str << "</UL>\n"
            end
            ERB.new(str).result(binding)
          end
        end
      end

      class URLMapperEx < URLMapper
        def library_url(name)
          if name == '/'
            "/library/index.html"
          else
            "/library/#{encodename_fs(name)}.html"
          end
        end

        def class_url(name)
          "/class/#{encodename_fs(name)}.html"
        end

        def method_url(spec)
          cname, tmark, mname = *split_method_spec(spec)
          "/method/#{encodename_fs(cname)}/#{typemark2char(tmark)}/#{encodename_fs(mname)}.html"
        end

        def document_url(name)
          "/doc/#{encodename_fs(name)}.html"
        end
      end

      def initialize
        super
        @sitemap = {
          :library => Sitemap.new('ライブラリ', 'library/index.html'),
        }
        @sitemap[:library] << Sitemap::Content.new('標準ライブラリ', 'library/_builtin.html')
        @sitemap[:library] << Sitemap::Content.new('添付ライブラリ')
        @stdlibs = {}
        @index_contents = []
        @parser.banner = "Usage: #{File.basename($0, '.*')} chm [options]"
        @parser.on('-o', '--outputdir=PATH', 'Output directory') do |path|
          begin
            @outputdir = Pathname.new(path).realpath
          rescue Errno::ENOENT
            FileUtils.mkdir_p(path, :verbose => true)
            retry
          end
        end
      end

      def exec(argv, options)
        create_manager_config
        prefix = options[:prefix]
        db = MethodDatabase.new(prefix.to_s)
        manager = ScreenManager.new(@manager_config)
        @html_files = []
        db.transaction do
          methods = {}
          db.methods.each do |entry|
            method_name = entry.klass.name + entry.typemark + entry.name
            (methods[method_name] ||= []) << entry
          end

          entries = db.docs + db.libraries.sort + db.classes.sort + methods.values.sort
          pb = ProgressBar.create(title: 'entry', total: entries.size)
          entries.each do |c|
            filename = create_html_file(c, manager, @outputdir, db)
            @html_files << filename
            e = c.is_a?(Array) ? c.sort.first : c
            case e.type_id
            when :library
              content = Sitemap::Content.new(e.name.to_s, filename)
              if e.name.to_s != '_builtin'
                @sitemap[:library][1] << content
                @stdlibs[e.name.to_s] = content
              end
              @index_contents << Sitemap::Content.new(e.name.to_s, filename)
            when :class
              content = Sitemap::Content.new(e.name.to_s, filename)
              if e.library.name.to_s == '_builtin'
                @sitemap[:library][0] << content
              else
                @stdlibs[e.library.name.to_s] << content
              end
              @index_contents << Sitemap::Content.new("#{e.name} (#{e.library.name})", filename)
            when :method
              e.names.each do |e_name|
                name = e.typename == :special_variable ? "$#{e_name}" : e_name
                @index_contents <<
                  Sitemap::Content.new("#{name} (#{e.library.name} - #{e.klass.name})", filename)
                @index_contents <<
                  Sitemap::Content.new("#{e.klass.name}#{e.typemark}#{name} (#{e.library.name})", filename)
              end
            end
            pb.title = align_progress_bar_title(e.name)
            pb.increment
          end
          pb.finish
        end
        @html_files.sort!
        create_file(@outputdir + 'refm.hhp', HHP_SKEL)
        create_file(@outputdir + 'refm.hhc', HHC_SKEL)
        create_file(@outputdir + 'refm.hhk', HHK_SKEL)
        create_file(@outputdir + 'library/index.html', manager.library_index_screen(db.libraries.sort, {:database => db}).body)
        create_file(@outputdir + 'class/index.html', manager.class_index_screen(db.classes.sort, {:database => db}).body)
        FileUtils.cp(@manager_config[:themedir] + @manager_config[:css_url],
                     @outputdir.to_s, {:verbose => true, :preserve => true})
      end

      private

      def create_manager_config
        @manager_config = {
          :baseurl     => 'http://example.com/',
          :suffix      => '.html',
          :catalogdir  => srcdir_root + 'data'+ 'bitclust' + 'catalog',
          :templatedir => srcdir_root + 'data'+ 'bitclust' + 'template',
          :themedir    => srcdir_root + 'theme' + 'default',
          :css_url     => 'style.css',
          :cgi_url     => '',
          :tochm_mode  => true
        }
        @manager_config[:urlmapper] = URLMapperEx.new(@manager_config)
      end

      FIX_UNDEF = { "\u00a5" => '\\', # encode MS unicode to Windows-31J as much as possible
                    "\u00b7" => "\uff65",
                    "\u0308" => "\u2025",
                    "\u2014" => "\u2015",
                    "\u2212" => "\uff0d",
                    "\u301c" => "\uff5e" } 

      def create_html_file(entry, manager, outputdir, db)
        html = manager.entry_screen(entry, {:database => db}).body
        e = entry.is_a?(Array) ? entry.sort.first : entry
        path = case e.type_id
               when :library, :class, :doc
                 outputdir + e.type_id.to_s + (NameUtils.encodename_fs(e.name) + '.html')
               when :method
                 outputdir + e.type_id.to_s + NameUtils.encodename_fs(e.klass.name) +
                   e.typechar + (NameUtils.encodename_fs(e.name) + '.html')
               else
                 raise
               end
        FileUtils.mkdir_p(path.dirname) unless path.dirname.directory?

        begin
          new_html = html.gsub(/charset=utf-8/i, 'charset=Windows-31J').
                     encode('windows-31j', { :fallback => FIX_UNDEF })
          mode = 'w:windows-31j'
        rescue
          new_html = html # write file as it is, utf-8
          mode = 'w:utf-8'
        end
        path.open(mode) do |f|
          f.write(new_html)
        end
        path.relative_path_from(outputdir).to_s
      end

      def create_file(path, skel)
        $stderr.print("creating #{path} ...")
        str = ERB.new(skel).result(binding).
              gsub(/charset=utf-8/i, 'charset=Windows-31J').
              encode('windows-31j', { :fallback => FIX_UNDEF } )
        path.open('w:windows-31j') do |f|
          f.write(str)
        end
        $stderr.puts(" done.")
      end
    end
  end
end
