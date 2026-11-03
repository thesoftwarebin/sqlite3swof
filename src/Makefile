CFLAGS+=-DSQLITE_DQS=0 -DSQLITE_USE_W32_FOR_CONSOLE_IO -DSQLITE_ENABLE_IOTRACE -DSQLITE_ENABLE_PREUPDATE_HOOK -DSQLITE_ENABLE_SESSION -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_GEOPOLY -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_DBSTAT_VTAB -DSQLITE_ENABLE_RBU -DSQLITE_SOUNDEX -DSQLITE_HAVE_ZLIB -DSQLITE_ENABLE_DESERIALIZE -O2 -Wall -c -fmessage-length=0

LDFLAGS=-static -Xlinker --strip-debug
OBJS=loadembeddeddb.o sqlite3.o libfmemopen.o shell.o embeddeddb.o

LIB="-lz"

DEPS = $(wildcard *.d)

sqlite3swof.exe: $(OBJS)
	$(CC) $(LDFLAGS) -o sqlite3swof.exe $(OBJS) $(LIB)

embeddeddb.o: embeddeddb.rc
	mkdir -p src && windres -i embeddeddb.rc -o $@

%.o: %c.c
	$(CC) $(CFLAGS) -o$@ $<
	$(CC) -MM $(CFLAGS) $< > $(@:.o=.d)

-include $(DEPS)

clean:
	$(RM) -vf $(OBJS) sqlite3swof.exe

bootstrap:
	./sqlite3swof.exe :memory: ".echo off" ".ar --create" ".ar --glob --insert ../assets/scripts_dist/main.sql ../assets/scripts_dist/help.sql ../assets/scripts_dist/sqlite3swof" "update sqlar set name=replace(name, '../assets/scripts_dist/', '') where name like '../assets/scripts_dist/%'" ".ar --remove sqlite3swof/clone/db" ".ar --verbose --insert sqlite3swof.exe" "update sqlar set name='sqlite3swof/clone/template/sqlite3swof.0.exe' where name='sqlite3swof.exe'" ".ar --verbose --list" ".read :ar:sqlite3swof/clone/scripts/clone.sql"

