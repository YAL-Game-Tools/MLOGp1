# MLOG+1

A web-based editor and source-to-source compiler for people that don't mind assembly but want something more laconic than what Mindustry offers by default -
historically, assembly languages leaned towards short instruction names
(sometimes leading to names like `CVTPS2PD` in extended instruction sets), but MLOG is all but the opposite of that with `jump greaterThan i 0`.

Therefore, the purpose of the tool is to offer shorthand versions of common instructions without making the whole thing much less "assembly-er" - there's a handful of other people's compilers for that.

## Shorthands

### Named labels

Which apparently v6+ has, despite the only mention of it being in patch notes somewhere.

Any instruction can be preceded by a `labelName:`, and labels may occupy separate lines as well.

### multiple instructions per line

You can do
```
instruction1; instruction2
```
instead of
```
instruction1
instruction2
```
if you really want.

### `jump` extensions
Instruction now can be used as just `jump labelName` for unconditional jumps (`jump labelName always 0 0`).

### `if`

A convenience wrapper for `jump`, syntax as following
```
if a op b [then] instruction
# or
if a op b [then]
	...instructions
endif
# or
if a op b [then]
	...instructions
else instruction
# or
if a op b [then]
	...instructions
else
	...instructions
endif
```
So
```
am_dead = @unit.@dead
if am_dead == true end
```
becomes
```
sensor am_dead @unit @dead
jump 3 notEqual am_dead true
    end
# end if (pc:0)
```
and
```
if debug == true
    _x = @unit.@x
    _y = @unit.@y
    printflush cout "We're at" _x ", " _y
endif
```
becomes
```
jump 8 notEqual debug true
    sensor _x @unit @x
    sensor _y @unit @y
    print "We're at"
    print _x
    print ", "
    print _y
    printflush cout
# end if (pc:0)
```

`if`-blocks containing a single unconditional `jump` will be turned into a single `jump` instruction, so
```
if am_dead == true jump find_a_unit
...
find_a_unit:
```
becomes
```
jump <offset> equal _dead true # dest: find_a_unit
```

### `print` extensions
Instruction now accepts trailing arguments to produce multiple `print` instructions, so
```
print "x:" @thisx ", y:" @thisy
```
becomes
```
print "x:"
print @thisx
print ", y:"
print @thisy
```

### `printflush` extensions
Instruction now can be used with trailing arguments to produce one or more `print` instructions before it, so
```
printflush message1 "x:" @thisx ", y:" @thisy
```
becomes
```
print "x:"
print @thisx
print ", y:"
print @thisy
printflush message1
```

### Variable-related shorthands
You can do the following:

<table><tr><th>
MLOG+1
</th><th>
Generated MLOG
</th><th>
Notes
</th></tr>
<tr><td>

```
varname = value
```
	
</td><td>

```
set varname value
```

</td><td>

</td></tr>
<tr><td>

```
varname = value1 + value2
```
	
</td><td>

```
op varname add varname value1 value2
```

</td><td>

Most C-style binary operators are supported;  
see `binOpToLogOp` in [LogicOperator.hx](https://github.com/YAL-Game-Tools/MLOGp1/blob/main/src/compiler/LogicOperator.hx) for full list.

</td></tr>
<tr><td>

```
varname = value1 add value2
```
	
</td><td>

```
op varname add varname value1 value2
```

</td><td>

Same as above

</td></tr>
<tr><td>

```
varname = min(value1, value2)
varname = sin(angle)
```
	
</td><td>

```
op min varname value1 value2
op sin varname angle 0
```

</td><td>

Also same as above

</td></tr>
<tr><td>

```
varname += value
```
	
</td><td>

```
op varname add varname varname value
```

</td><td>



</td></tr>
<tr><td>

```
varname = memory1[i]
memory1[i] = varname
```
	
</td><td>

```
read varname memory1 i
write varname memory1 i
```

</td><td>

Memory shorthands

</td></tr>
<tr><td>

```
varname = unit.@x
```
	
</td><td>

```
sensor varname unit @x
```

</td><td>

`sensor` shorthand

</td></tr>
</table>

### Macros

Macros are essentially custom instruction shorthands, defined as
```
macro macro_name
	...instructions
endmacro
macro_name
# or:
macro macro_name(...parameters)
	...instructions
endmacro
macro_name ...parameters # option 1
macro_name(...parameters) # option 2
```

for example,
```
macro ensure_unit
    _dead = @unit.@dead
    if _dead == true jump find_a_unit
endmacro
# ...
ensure_unit
```
becomes
```
# macro: ensure_unit
# ...
sensor _dead @unit @dead
jump 34 equal _dead true # dest: find_a_unit
```

and
```
macro dumpxy(u)
    set _x = u.@x
    set _y = u.@y
    printflush cout "x:"_x ",y:"_y
endmacro
# ...
dumpxy @unit
```
becomes
```
# macro: dumpxy
# ...
sensor _x @unit @x
sensor _y @unit @y
print "x:"
print _x
print ",y:"
print _y
printflush cout
```

By default, parameters will be processed MLOG-style (simple string/number/variable name/\@constant), but you can include arbitrary snippets by surrounding parameters in `{}`, so
```
macro ifdead(instr)
    _dead = @unit.@dead
    if _dead == true instr
endmacro
# ...
ifdead {countdown -= 1}
```
becomes
```
# macro: ifdead
# ...
sensor _dead @unit @dead
jump 3 notEqual _dead true
    op sub countdown countdown 1
# end if (pc:1)
```

## Quirks & Limitations

- Doesn't do much error checking as of yet
- Collapses labels into numeric IDs even though it doesn't really have to for v6+  
  (I was not aware of named label support in MLOG due to that not being documented)
- Only supports Latin variable names  
  (I was not aware that Mindustry allows _any non-space character_ to be used in variable names since this also isn't mentioned on the wiki - an adventure for another time)
  
## Compiling

```
haxe -cp src -js bin/script.js -main Main
```

## Meta
- Tool by [YellowAfterlife](https://yal.cc)
- Written in [Haxe](https://haxe.org)
- Uses [Ace editor](https://github.com/ajaxorg/ace)
- GPL 3.0