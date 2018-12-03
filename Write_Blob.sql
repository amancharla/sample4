set serveroutput on size 1000000;
declare

	vblob BLOB;
	vstart NUMBER := 1;
	bytelen NUMBER := 32000;
	len NUMBER;
	my_vr RAW(32000);
	x NUMBER;

	l_output utl_file.file_type;

BEGIN

-- define output directory
	l_output := utl_file.fopen('/opt/mis/apps/oraApps/EBCRDEV/apps/apps_st/comn/temp', 'Bill ToEnhancement.docx','wb', 32760);
	vstart := 1;
	bytelen := 32000;

-- get length of blob
	SELECT dbms_lob.getlength(atchmnt_name), atchmnt_file INTO len, vblob
           FROM QCC_CPQ.QCC_S2P_INVC_ATTCHS where attch_id = 6;     


-- save blob length
x := len; 

-- if small enough for a single write
IF len < 32760 THEN
	utl_file.put_raw(l_output,vblob);
	utl_file.fflush(l_output);
ELSE -- write in pieces
	vstart := 1;
	WHILE vstart < len and bytelen > 0
	LOOP
	   dbms_lob.read(vblob,bytelen,vstart,my_vr);

	   utl_file.put_raw(l_output,my_vr);
	   utl_file.fflush(l_output); 

	   -- set the start position for the next cut
	   vstart := vstart + bytelen;

	   -- set the end position if less than 32000 bytes
	   x := x - bytelen;
		   IF x < 32000 THEN
		      bytelen := x;
		   END IF;
	
	end loop;
END IF;
utl_file.fclose(l_output);
exception
when others then
         dbms_output.put_line('SQL ERROR '||SQLERRM);

utl_file.fclose(l_output);
End;