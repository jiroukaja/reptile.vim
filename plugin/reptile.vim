" reptile.vim
" Author: jiroukaja <jiroukaja@mac.com>
" Last Change: 02 Feb 2013.
" Version: 0.0.1
" Licence:     The MIT License {{{
"     Permission is hereby granted, free of charge, to any person obtaining a copy
"     of this software and associated documentation files (the "Software"), to deal
"     in the Software without restriction, including without limitation the rights
"     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
"     copies of the Software, and to permit persons to whom the Software is
"     furnished to do so, subject to the following conditions:
"
"     The above copyright notice and this permission notice shall be included in
"     all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
"     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
"     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
"     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
"     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
"     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
"     THE SOFTWARE.
" }}}
if exists("g:loaded_reptile")
  finish
endif
let g:loaded_reptile = 1
let s:save_cpo = &cpo
set cpo&vim

" Local values
let s:dictionary = type({})
let s:string = type("")

let s:no_check = 0

function! s:get_file_path(list)
  let l:list = a:list
  let l:lenght = len(l:list)
  if l:lenght == 0
    echoerr 'Set Path or Dictionary like ~/.vim/dict/xxx.dict or {{filetype} : {path_string}}'
    return
  endif

  if type(l:list) == s:dictionary
    " Check the lists has key &filetype.
    if has_key(l:list, &filetype)
      let l:file_arg = &filetype
      return l:list[file_arg]
    elseif type(l:list) == s:string
      return l:list
    else
      echoerr 'Invalid values'
      return
    endif
  endif
endfunction


function! s:add_word(file_path, word, checked)
  echo "type(file_path) = " . type(a:file_path) . ", type(word) = " . type(a:word) . ", type(checked) = " . type(a:checked)
  let file_path = a:file_path
  let word = a:word
  let checked = a:checked
  " Check path
  if !isdirectory(file_path) "filewritable(file_path)
    " Check directory
    call mkdir(fnamemodify(file_path, ':p:h'))
  endif
  
  " Add word in path, when not exists. check RegExp
  if l:check == s:no_check || join(readfile(l:file_path), "\n") =~ '^' . l:word . '$'
    " Already exists!
   echomsg "Already exists word: ". l:word
 else
    " Add <cword>
    execute ":redir! >> " . l:faile_path
      silent! echon l:word
    redir END
    echomsg "Add " . l:word . " in ". l:file_path
  endif
endfunction


function! reptile#cursor(path, ...)
  let file_path = s:get_file_path(a:path)
  let checked = get(a:, '1' , 0)
  let word = expand('<cword>')
  echon ", l:file_path = " . file_path . ", type() = " . type(file_path)
  echon ", l:check = " . checked . ", type() = " . type(checked)
  echon ", expand('<cword>') = " . expand('<cword>') . ", type() = " . type(expand('<cword>'))
  s:add_word(file_path, word, checked)
endfunction


function! reptile#selected(path, ...)

  let l:file_path = s:get_file_path(a:path)
  let l:check = get(a:, "1", 0)
  
  let save_z = getreg('z', 1)
  let save_z_type = getregtype('z')

  " Get selected in vmode
  try
    normal! gv"zy
    let l:selected = @z
  finally
    call setreg('z', save_z, save_z_type)
  endtry
  s:add_word(l:file_path, l:selected, l:check)
endfunction


command! -nargs=+ ReptileCword :call reptile#cursor(<args>)
command! -nargs=+ ReptileVword :call reptile#selected(<args>)

let &cpo = s:save_cpo

