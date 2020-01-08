# encoding: utf-8
ReVIEW::Compiler.defblock :talkleft, 1
ReVIEW::Compiler.defblock :talkright, 1
ReVIEW::Compiler.defblock :attention, 0
ReVIEW::Compiler.defblock :romanlist, 0
ReVIEW::Compiler.defblock :charintro, 1
ReVIEW::Compiler.defblock :list, 3
ReVIEW::Compiler.defsingle :focus, 0..1
ReVIEW::Compiler.definline :mathcode
ReVIEW::Compiler.definline :rubycode

module ReVIEW
  class HTMLBuilder
    # LINEっぽく、アイコンがしゃべってるみたいに、
    # セリフ内容を吹き出しで囲うやつ。
    #
    # η専用。
    # 空行に区切られた各文節を<p></p>する。
    #
    # linesが2行以上場合はηの口調が説明的であるので、字下げをオンにして見やすくするよ。
    # （1行のみのセリフを字下げすると、時差現が変な左の空白に見えるため）
    def talkleft(lines, who)
      speaker =
        case who
          # srcは64pxの画像
          when 'eta'
            {alt: 'η', src: 'images/eta.png'}
          when 'eta-arms'
            {alt: 'η∞', src: 'images/eta-arms.png'}
          when 'eta-sure'
            {alt: 'η:)', src: 'images/eta-sure.png'}
          when 'eta-smile'
            {alt: 'η=)', src: 'images/eta-smile.png'}
          when 'eta-light'
            {alt: 'η=D', src: 'images/eta-light.png'}
          when 'eta-thinking'
            {alt: 'η:(', src: 'images/eta-thinking.png'}
          when 'eta-blushed'
            {alt: 'η…', src: 'images/eta-blushed.png'}
          when 'eta-waver'
            {alt: 'η…💦', src: 'images/eta-waver.png'}
          when 'eta-waver-very'
            {alt: 'η…💦💦', src: 'images/eta-waver-very.png'}
          when 'invisible'
            # 演出等に、アイコンを出したくない時など
           {alt: '', src: ''}
          else
            raise "an unknown lefty speaker '#{who}'"
        end

      # TODO: 「行が2行以上」じゃなくて「\n\n」を確認する。（節が2つ以上）
      talk_left_sentence_desc = -> (child){
        if lines.length >= 2 then
          %Q(<div class="talk-left-sentence-desc">#{child}</div>)
        else
          child
        end
      }
      sentence = insert_space_after_japanese_punctuation(
        talk_left_sentence_desc.(make_talk_sentence(lines))
      )

      puts <<~EOS
        <div class="talk-left">
          <div class="talk-left-speaker">
            <img alt="#{speaker[:alt]}" src="#{speaker[:src]}"/>
          </div>
          <div class="talk-left-sentence">
            #{sentence}
          </div>
        </div>
      EOS
    end

    # talkleftと同じだけど、η以外。
    def talkright(lines, who)
      speaker =
        case who
          when 'mu'
            {alt: 'μ', src: 'images/mu.png'}
          when 'mu-saying'
            {alt: 'μ「」', src: 'images/mu-saying.png'}
          when 'mu-love'
            {alt: 'μ//', src: 'images/mu-love.png'}
          when 'mu-heart'
            {alt: 'μ♡', src: 'images/mu-heart.png'}
          when 'mu-wink'
            {alt: 'μ;)', src: 'images/mu-wink.png'}
          when 'mu-note'
            {alt: 'μ♪', src: 'images/mu-note.png'}
          when 'mu-smile'
            {alt: 'μ:)', src: 'images/mu-smile.png'}
          when 'mu-question'
            {alt: 'μ？', src: 'images/mu-question.png'}
          when 'somebody'
            # 現時点では誰が発声したのかわからない時など
           {alt: '', src: ''}
          else
            raise "an unknown rightly speaker '#{who}'"
        end

      talk_right_sentence_desc = -> (child){
        if lines.length >= 2 then
          %Q(<div class="talk-right-sentence-desc">#{child}</div>)
        else
          child
        end
      }
      sentence = insert_space_after_japanese_punctuation(
        talk_right_sentence_desc.(make_talk_sentence(lines))
      )

      puts <<~EOS
        <div class="talk-right">
          <div class="talk-right-sentence">
            #{sentence}
          </div>
          <div class="talk-right-speaker">
            <img alt="#{speaker[:alt]}" src="#{speaker[:src]}"/>
          </div>
        </div>
      EOS
    end

    # @param [string] pos 'left' or 'right'
    # @param [{alt: string, src: string}] speaker an img
    #
    # >>> make_talk_sentence(['ああ、', 'うん。', '', 'そう。'])
    # "<div>ああ、うん。</div><div>そう。</div>"
    private def make_talk_sentence(lines)
      clauses = splitBy(lines, ->(x){ x == '' }).map {|clause|
        clause.join
      }
      clauses.map {|clause|
        "<p>#{clause}</p>"
      }.join
    end

    # @param [array of T] xs
    # @param [T -> bool] p a predicate for xs
    #
    # >>> p splitBy([10, 20, 0, 10, 0, 20], ->(x){ x == 0 })
    # [[10, 20], [10], [20]]
    private def splitBy(xs, p)
      result = []
      child = []
      for x in xs do
        if p.(x) then
          result += [child]
          child = []
        else
          child += [x]
        end
      end
      result += [child]
      result
    end

    def attention(lines)
      children = lines.map {|line|
        %Q(<p class="attention-line">#{line}</p>)
      }
      puts %Q(<div class="attention">#{children.join}</div>)
    end

    def romanlist(lines)
      list_items = lines.map {|line|
        %Q(<li>#{line}</li>)
      }
      puts %Q(<ul class="romanlist">#{list_items.join}</ul>)
    end

    def charintro(lines, image_path)
      sentence = lines.map {|line|
        %Q(<p>#{line}</p>)
      }.join

      puts %Q(
        <div class="character-intro">
          <div>#{sentence}</div>
          <img src="#{image_path}" alt="キャラクターアイコン" />
        </div>
      )
    end

    def list(lines, id, caption, lang = nil)
      puts %Q(<div id="#{normalize_id(id)}" class="caption-code">)
      math_lines = lines.map {|line| mathematical_code(line)}
      list_body id, math_lines, lang
      begin
        list_header id, caption, lang
      rescue KeyError
        error "no such list: #{id}"
      end
      puts '</div>'
    end

    # ηの考え事が中心の章から、μとの会話が中心の章へ移る時に、
    # 後者の章の冒頭に入れるやつ。
    def focus(symbol = '◆')
      puts %Q(<p class="focus">#{symbol}　#{symbol}　#{symbol}</p>)
    end

    # A kind of `code`.
    # Regards a suffix number to a sup
    def inline_mathcode(s)
      %Q(<code class="inline-code tt">#{mathematical_code(s)}</code>)
    end

    def inline_rubycode(s)
      %Q(<code class="inline-code tt">#{inline_ruby(s)}</code></ruby>)
    end

    # # footnoteの採番をブラウザでやらせようとして挫折
    # # vivliostyle.jsがIDを書き換えてしまい、参照できなくなってしまう
    # # target-counter を使ったやりかた
    # def footnote(id, str)
    #     puts %Q(<p class="footnote" id="fn-#{normalize_id(id)}">
    #             <span>#{compile_inline(str)}</span></p>)
    # end
    # def inline_fn(id)
    #     # 番号はCSSで出すので気にしない
    #     %Q(<a id="fnb-#{normalize_id(id)}" href="#fn-#{normalize_id(id)}"
    #        class="noteref"><!--#{@chapter.footnote(id).number}--></a>)
    # end
  end

  module BuilderOverride
    Compiler.definline :bruby

    def inline_bruby(s)
      "<b>#{inline_ruby(s)}</b>"
    end
  end

  class Builder
    prepend BuilderOverride
  end
end

def insert_space_after_japanese_punctuation(sentence)
  punctuations = '！？♪'
  sentence.gsub(/([#{punctuations}])([^\s　」』…#{punctuations}])/, '\1　\2')
end

def mathematical_code(s)
  names = '[A-Za-zαβγδεζηθικλμνξοπρστυφχψω≦≧＜＞]'
  indice = '[0-9a-zA-Z\-,]'
  mathematical = s.gsub(/(#{names})_(#{indice})/, '\1<sub>\2</sub>')
  mathematical = mathematical.gsub(/(#{names})\^(#{indice})/, '\1<sup>\2</sup>')

  mathematical = mathematical.gsub(/(#{names})_\${(#{indice}+)}\$/, '\1<sub>{\2}</sub>')
  mathematical = mathematical.gsub(/(#{names})\^\${(#{indice}+)}\$/, '\1<sup>{\2}</sup>')

  mathematical = mathematical.gsub(/(#{names})_{(#{indice}+)}/, '\1<sub>\2</sub>')
  mathematical = mathematical.gsub(/(#{names})\^{(#{indice}+)}/, '\1<sup>\2</sup>')
  mathematical
end
