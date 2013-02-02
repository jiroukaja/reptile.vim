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

function! s:get_file_path(...)
  let l:lenght = a:0
  if l:lenght == 0
    echoerr 'Set Path or Dictionary like {{filetype} : {path_string}}'
    return
  endif

  let l:list = a:1

  if type(l:list) == s:dictionary
    " Check the lists has key &filetype.
    if l:length > 2
      echomsg 'Too many vars. (dictionary, string)'
    endif
    if has_key(l:list, &filetype)
      let l:file_arg = &filetype
    else
      " 'default' when &filetype doesn't exist.
      let l:file_arg = a:2
      if !has_key(l:list, l:file_arg)
        echoerr 'Invalid default filetype'
        return
      endif
    endif
    return l:list[file_arg]
  elseif type(l:list) == s:string
    if l:lenght > 1
      echomsg 'Too many vars.'
    endif
    return a:var_list[0]
  else
    echoerr 'Invalid values'
    return
  endif
endfunction


function! s:add_word(file_path, word, check)
  " Check path
  if !isdirectory(a:file_path) "filewritable(file_path)
    " Check directory
    call mkdir(fnamemodify(a:file_path, ':p:h'))
  endif
  
  " Add word in path, when not exists. check RegExp
  if a:check == s:no_check || join(readfile(a:file_path), "\n") =~ '^' . a:word . '$'
    " Already exists!
   echomsg "Already exists word: ". a:word
 else
    " Add <cword>
    execute ":redir! >> " . a:faile_path
      silent! echon a:word
    redir END
    echomsg "Add " . a:word . " in ". a:file_path
  endif
endfunction


function! reptile#cursor(path, ...)

  let l:file_path = s:get_file_path(a:path)
  let l:check = get(a:, "1" , 0)
  s:add_word(l:file_path, expand('<cword>'), l:check)
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


command! -nargs=+ ReptileCword :call reptile#cursor(<f-args>)
command! -nargs=+ ReptileVword :call reptile#selected(<f-args>)

let &cpo = s:save_cpo

