/*
nochump.util.zip.ZipConstants
Copyright (C) 2007 David Chang (dchang@nochump.com)

This file is part of nochump.util.zip.

nochump.util.zip is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

nochump.util.zip is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.nochump.zip {
	
	public class ZipConstants {
		
		/* The local file header */
		public static const LOCSIG:uint = 0x04034b50;	// "PK\003\004"
		public static const LOCHDR:uint = 30;	// LOC header size
		public static const LOCVER:uint = 4;	// version needed to extract
		//public static const LOCFLG:uint = 6; // general purpose bit flag
		//public static const LOCHOW:uint = 8; // compression method
		//public static const LOCTIM:uint = 10; // modification time
		//public static const LOCCRC:uint = 14; // uncompressed file crc-32 value
		//public static const LOCSIZ:uint = 18; // compressed size
		//public static const LOCLEN:uint = 22; // uncompressed size
		public static const LOCNAM:uint = 26; // filename length
		//public static const LOCEXT:uint = 28; // extra field length
		
		/* The Data descriptor */
		public static const EXTSIG:uint = 0x08074b50;	// "PK\007\008"
		public static const EXTHDR:uint = 16;	// EXT header size
		//public static const EXTCRC:uint = 4; // uncompressed file crc-32 value
		//public static const EXTSIZ:uint = 8; // compressed size
		//public static const EXTLEN:uint = 12; // uncompressed size
		
		/* The central directory file header */
		public static const CENSIG:uint = 0x02014b50;	// "PK\001\002"
		public static const CENHDR:uint = 46;	// CEN header size
		//public static const CENVEM:uint = 4; // version made by
		public static const CENVER:uint = 6; // version needed to extract
		//public static const CENFLG:uint = 8; // encrypt, decrypt flags
		//public static const CENHOW:uint = 10; // compression method
		//public static const CENTIM:uint = 12; // modification time
		//public static const CENCRC:uint = 16; // uncompressed file crc-32 value
		//public static const CENSIZ:uint = 20; // compressed size
		//public static const CENLEN:uint = 24; // uncompressed size
		public static const CENNAM:uint = 28; // filename length
		//public static const CENEXT:uint = 30; // extra field length
		//public static const CENCOM:uint = 32; // comment length
		//public static const CENDSK:uint = 34; // disk number start
		//public static const CENATT:uint = 36; // public file attributes
		//public static const CENATX:uint = 38; // external file attributes
		public static const CENOFF:uint = 42; // LOC header offset
		
		/* The entries in the end of central directory */
		public static const ENDSIG:uint = 0x06054b50;	// "PK\005\006"
		public static const ENDHDR:uint = 22; // END header size
		//public static const ENDSUB:uint = 8; // number of entries on this disk
		public static const ENDTOT:uint = 10;	// total number of entries
		//public static const ENDSIZ:uint = 12; // central directory size in bytes
		public static const ENDOFF:uint = 16; // offset of first CEN header
		//public static const ENDCOM:uint = 20; // zip file comment length
		
		/* Compression methods */
		public static const STORED:uint = 0;
		public static const DEFLATED:uint = 8;
		
	}

}