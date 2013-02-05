" reptile.vim
" Author: jiroukaja <jiroukaja@mac.com>
" Last Change: 05 Feb 2013.
" Version: 0.1
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
  let l:file_path = a:file_path
  let l:file_directory = fnamemodify(l:file_path, ':p:h')
  let l:word = a:word
  let l:checked = a:checked
  " Check path
  if !isdirectory(l:file_directory) "filewritable(file_path)
    " Check directory
    call mkdir(l:file_directory)
  endif
  
  " Add word in path, when not exists. check RegExp
  if l:checked == s:no_check || "\n" . join(readfile(l:file_path), "\n") =~ "\n" . l:word . "\n"
    " Already exists!
    echomsg "Already exists word: " . l:word . " in " . l:file_path
  else
    " Add <cword>
    silent! execute ":! echo " . l:word . " >> " . l:file_path
    echomsg "Add " . l:word . " in ". l:file_path
  endif
endfunction


function! reptile#cursor(path, ...)
  let l:file_path = s:get_file_path(a:path)
  let l:checked = get(a:, '1' , 0)
  let l:word = expand('<cword>')
  call s:add_word(l:file_path, l:word, l:checked)
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
  call s:add_word(l:file_path, l:selected, l:check)
endfunction

function! reptile#tab_open()
  let l:file_path = s:get_file_path(g:reptile_previous_file_path)
  execute ":tabe " . l:file_path
endfunction

function! reptile#open()
  let l:file_path = s:get_file_path(g:reptile_previous_file_path)
  execute ":edit " . l:file_path
endfunction


command -nargs=+ ReptileCword :call reptile#cursor(<args>)
command -nargs=+ ReptileVword :call reptile#selected(<args>)
command -nargs=0 ReptileTabOpen :call reptile#tab_open()
command -nargs=0 ReptileOpen :call reptile#open()

let &cpo = s:save_cpo

