library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
package crc is
type crc32table_t is array (integer range <>) of std_logic_vector(32 - 1 downto 0);

-- crc32, polynomial 0x04c11db7, 8 bits at once, reversed

constant crc32table8 : crc32table_t (0 to 2**8 - 1) := (
	32x"00000000", 	32x"77073096", 	32x"ee0e612c", 	32x"990951ba", 
	32x"076dc419", 	32x"706af48f", 	32x"e963a535", 	32x"9e6495a3", 
	32x"0edb8832", 	32x"79dcb8a4", 	32x"e0d5e91e", 	32x"97d2d988", 
	32x"09b64c2b", 	32x"7eb17cbd", 	32x"e7b82d07", 	32x"90bf1d91", 
	32x"1db71064", 	32x"6ab020f2", 	32x"f3b97148", 	32x"84be41de", 
	32x"1adad47d", 	32x"6ddde4eb", 	32x"f4d4b551", 	32x"83d385c7", 
	32x"136c9856", 	32x"646ba8c0", 	32x"fd62f97a", 	32x"8a65c9ec", 
	32x"14015c4f", 	32x"63066cd9", 	32x"fa0f3d63", 	32x"8d080df5", 
	32x"3b6e20c8", 	32x"4c69105e", 	32x"d56041e4", 	32x"a2677172", 
	32x"3c03e4d1", 	32x"4b04d447", 	32x"d20d85fd", 	32x"a50ab56b", 
	32x"35b5a8fa", 	32x"42b2986c", 	32x"dbbbc9d6", 	32x"acbcf940", 
	32x"32d86ce3", 	32x"45df5c75", 	32x"dcd60dcf", 	32x"abd13d59", 
	32x"26d930ac", 	32x"51de003a", 	32x"c8d75180", 	32x"bfd06116", 
	32x"21b4f4b5", 	32x"56b3c423", 	32x"cfba9599", 	32x"b8bda50f", 
	32x"2802b89e", 	32x"5f058808", 	32x"c60cd9b2", 	32x"b10be924", 
	32x"2f6f7c87", 	32x"58684c11", 	32x"c1611dab", 	32x"b6662d3d", 
	32x"76dc4190", 	32x"01db7106", 	32x"98d220bc", 	32x"efd5102a", 
	32x"71b18589", 	32x"06b6b51f", 	32x"9fbfe4a5", 	32x"e8b8d433", 
	32x"7807c9a2", 	32x"0f00f934", 	32x"9609a88e", 	32x"e10e9818", 
	32x"7f6a0dbb", 	32x"086d3d2d", 	32x"91646c97", 	32x"e6635c01", 
	32x"6b6b51f4", 	32x"1c6c6162", 	32x"856530d8", 	32x"f262004e", 
	32x"6c0695ed", 	32x"1b01a57b", 	32x"8208f4c1", 	32x"f50fc457", 
	32x"65b0d9c6", 	32x"12b7e950", 	32x"8bbeb8ea", 	32x"fcb9887c", 
	32x"62dd1ddf", 	32x"15da2d49", 	32x"8cd37cf3", 	32x"fbd44c65", 
	32x"4db26158", 	32x"3ab551ce", 	32x"a3bc0074", 	32x"d4bb30e2", 
	32x"4adfa541", 	32x"3dd895d7", 	32x"a4d1c46d", 	32x"d3d6f4fb", 
	32x"4369e96a", 	32x"346ed9fc", 	32x"ad678846", 	32x"da60b8d0", 
	32x"44042d73", 	32x"33031de5", 	32x"aa0a4c5f", 	32x"dd0d7cc9", 
	32x"5005713c", 	32x"270241aa", 	32x"be0b1010", 	32x"c90c2086", 
	32x"5768b525", 	32x"206f85b3", 	32x"b966d409", 	32x"ce61e49f", 
	32x"5edef90e", 	32x"29d9c998", 	32x"b0d09822", 	32x"c7d7a8b4", 
	32x"59b33d17", 	32x"2eb40d81", 	32x"b7bd5c3b", 	32x"c0ba6cad", 
	32x"edb88320", 	32x"9abfb3b6", 	32x"03b6e20c", 	32x"74b1d29a", 
	32x"ead54739", 	32x"9dd277af", 	32x"04db2615", 	32x"73dc1683", 
	32x"e3630b12", 	32x"94643b84", 	32x"0d6d6a3e", 	32x"7a6a5aa8", 
	32x"e40ecf0b", 	32x"9309ff9d", 	32x"0a00ae27", 	32x"7d079eb1", 
	32x"f00f9344", 	32x"8708a3d2", 	32x"1e01f268", 	32x"6906c2fe", 
	32x"f762575d", 	32x"806567cb", 	32x"196c3671", 	32x"6e6b06e7", 
	32x"fed41b76", 	32x"89d32be0", 	32x"10da7a5a", 	32x"67dd4acc", 
	32x"f9b9df6f", 	32x"8ebeeff9", 	32x"17b7be43", 	32x"60b08ed5", 
	32x"d6d6a3e8", 	32x"a1d1937e", 	32x"38d8c2c4", 	32x"4fdff252", 
	32x"d1bb67f1", 	32x"a6bc5767", 	32x"3fb506dd", 	32x"48b2364b", 
	32x"d80d2bda", 	32x"af0a1b4c", 	32x"36034af6", 	32x"41047a60", 
	32x"df60efc3", 	32x"a867df55", 	32x"316e8eef", 	32x"4669be79", 
	32x"cb61b38c", 	32x"bc66831a", 	32x"256fd2a0", 	32x"5268e236", 
	32x"cc0c7795", 	32x"bb0b4703", 	32x"220216b9", 	32x"5505262f", 
	32x"c5ba3bbe", 	32x"b2bd0b28", 	32x"2bb45a92", 	32x"5cb36a04", 
	32x"c2d7ffa7", 	32x"b5d0cf31", 	32x"2cd99e8b", 	32x"5bdeae1d", 
	32x"9b64c2b0", 	32x"ec63f226", 	32x"756aa39c", 	32x"026d930a", 
	32x"9c0906a9", 	32x"eb0e363f", 	32x"72076785", 	32x"05005713", 
	32x"95bf4a82", 	32x"e2b87a14", 	32x"7bb12bae", 	32x"0cb61b38", 
	32x"92d28e9b", 	32x"e5d5be0d", 	32x"7cdcefb7", 	32x"0bdbdf21", 
	32x"86d3d2d4", 	32x"f1d4e242", 	32x"68ddb3f8", 	32x"1fda836e", 
	32x"81be16cd", 	32x"f6b9265b", 	32x"6fb077e1", 	32x"18b74777", 
	32x"88085ae6", 	32x"ff0f6a70", 	32x"66063bca", 	32x"11010b5c", 
	32x"8f659eff", 	32x"f862ae69", 	32x"616bffd3", 	32x"166ccf45", 
	32x"a00ae278", 	32x"d70dd2ee", 	32x"4e048354", 	32x"3903b3c2", 
	32x"a7672661", 	32x"d06016f7", 	32x"4969474d", 	32x"3e6e77db", 
	32x"aed16a4a", 	32x"d9d65adc", 	32x"40df0b66", 	32x"37d83bf0", 
	32x"a9bcae53", 	32x"debb9ec5", 	32x"47b2cf7f", 	32x"30b5ffe9", 
	32x"bdbdf21c", 	32x"cabac28a", 	32x"53b39330", 	32x"24b4a3a6", 
	32x"bad03605", 	32x"cdd70693", 	32x"54de5729", 	32x"23d967bf", 
	32x"b3667a2e", 	32x"c4614ab8", 	32x"5d681b02", 	32x"2a6f2b94", 
	32x"b40bbe37", 	32x"c30c8ea1", 	32x"5a05df1b", 	32x"2d02ef8d"
);



-- crc32, polynomial 0x04c11db7, 4 bits at once, reversed

constant crc32table4 : crc32table_t (0 to 2**4 - 1) := (
	32x"00000000", 	32x"1db71064", 	32x"3b6e20c8", 	32x"26d930ac", 
	32x"76dc4190", 	32x"6b6b51f4", 	32x"4db26158", 	32x"5005713c", 
	32x"edb88320", 	32x"f00f9344", 	32x"d6d6a3e8", 	32x"cb61b38c", 
	32x"9b64c2b0", 	32x"86d3d2d4", 	32x"a00ae278", 	32x"bdbdf21c"
);



-- crc32, polynomial 0x04c11db7, 2 bits at once, reversed

constant crc32table2 : crc32table_t (0 to 2**2 - 1) := (
	32x"00000000", 	32x"76dc4190", 	32x"edb88320", 	32x"9b64c2b0"
);



-- crc32, polynomial 0x04c11db7, 1 bits at once, reversed

constant crc32table1 : crc32table_t (0 to 2**1 - 1) := (
	32x"00000000", 	32x"edb88320"
);



-- crc32c, polynomial 0x1edc6f41, 8 bits at once, reversed

constant crc32ctable8 : crc32table_t (0 to 2**8 - 1) := (
	32x"00000000", 	32x"f26b8303", 	32x"e13b70f7", 	32x"1350f3f4", 
	32x"c79a971f", 	32x"35f1141c", 	32x"26a1e7e8", 	32x"d4ca64eb", 
	32x"8ad958cf", 	32x"78b2dbcc", 	32x"6be22838", 	32x"9989ab3b", 
	32x"4d43cfd0", 	32x"bf284cd3", 	32x"ac78bf27", 	32x"5e133c24", 
	32x"105ec76f", 	32x"e235446c", 	32x"f165b798", 	32x"030e349b", 
	32x"d7c45070", 	32x"25afd373", 	32x"36ff2087", 	32x"c494a384", 
	32x"9a879fa0", 	32x"68ec1ca3", 	32x"7bbcef57", 	32x"89d76c54", 
	32x"5d1d08bf", 	32x"af768bbc", 	32x"bc267848", 	32x"4e4dfb4b", 
	32x"20bd8ede", 	32x"d2d60ddd", 	32x"c186fe29", 	32x"33ed7d2a", 
	32x"e72719c1", 	32x"154c9ac2", 	32x"061c6936", 	32x"f477ea35", 
	32x"aa64d611", 	32x"580f5512", 	32x"4b5fa6e6", 	32x"b93425e5", 
	32x"6dfe410e", 	32x"9f95c20d", 	32x"8cc531f9", 	32x"7eaeb2fa", 
	32x"30e349b1", 	32x"c288cab2", 	32x"d1d83946", 	32x"23b3ba45", 
	32x"f779deae", 	32x"05125dad", 	32x"1642ae59", 	32x"e4292d5a", 
	32x"ba3a117e", 	32x"4851927d", 	32x"5b016189", 	32x"a96ae28a", 
	32x"7da08661", 	32x"8fcb0562", 	32x"9c9bf696", 	32x"6ef07595", 
	32x"417b1dbc", 	32x"b3109ebf", 	32x"a0406d4b", 	32x"522bee48", 
	32x"86e18aa3", 	32x"748a09a0", 	32x"67dafa54", 	32x"95b17957", 
	32x"cba24573", 	32x"39c9c670", 	32x"2a993584", 	32x"d8f2b687", 
	32x"0c38d26c", 	32x"fe53516f", 	32x"ed03a29b", 	32x"1f682198", 
	32x"5125dad3", 	32x"a34e59d0", 	32x"b01eaa24", 	32x"42752927", 
	32x"96bf4dcc", 	32x"64d4cecf", 	32x"77843d3b", 	32x"85efbe38", 
	32x"dbfc821c", 	32x"2997011f", 	32x"3ac7f2eb", 	32x"c8ac71e8", 
	32x"1c661503", 	32x"ee0d9600", 	32x"fd5d65f4", 	32x"0f36e6f7", 
	32x"61c69362", 	32x"93ad1061", 	32x"80fde395", 	32x"72966096", 
	32x"a65c047d", 	32x"5437877e", 	32x"4767748a", 	32x"b50cf789", 
	32x"eb1fcbad", 	32x"197448ae", 	32x"0a24bb5a", 	32x"f84f3859", 
	32x"2c855cb2", 	32x"deeedfb1", 	32x"cdbe2c45", 	32x"3fd5af46", 
	32x"7198540d", 	32x"83f3d70e", 	32x"90a324fa", 	32x"62c8a7f9", 
	32x"b602c312", 	32x"44694011", 	32x"5739b3e5", 	32x"a55230e6", 
	32x"fb410cc2", 	32x"092a8fc1", 	32x"1a7a7c35", 	32x"e811ff36", 
	32x"3cdb9bdd", 	32x"ceb018de", 	32x"dde0eb2a", 	32x"2f8b6829", 
	32x"82f63b78", 	32x"709db87b", 	32x"63cd4b8f", 	32x"91a6c88c", 
	32x"456cac67", 	32x"b7072f64", 	32x"a457dc90", 	32x"563c5f93", 
	32x"082f63b7", 	32x"fa44e0b4", 	32x"e9141340", 	32x"1b7f9043", 
	32x"cfb5f4a8", 	32x"3dde77ab", 	32x"2e8e845f", 	32x"dce5075c", 
	32x"92a8fc17", 	32x"60c37f14", 	32x"73938ce0", 	32x"81f80fe3", 
	32x"55326b08", 	32x"a759e80b", 	32x"b4091bff", 	32x"466298fc", 
	32x"1871a4d8", 	32x"ea1a27db", 	32x"f94ad42f", 	32x"0b21572c", 
	32x"dfeb33c7", 	32x"2d80b0c4", 	32x"3ed04330", 	32x"ccbbc033", 
	32x"a24bb5a6", 	32x"502036a5", 	32x"4370c551", 	32x"b11b4652", 
	32x"65d122b9", 	32x"97baa1ba", 	32x"84ea524e", 	32x"7681d14d", 
	32x"2892ed69", 	32x"daf96e6a", 	32x"c9a99d9e", 	32x"3bc21e9d", 
	32x"ef087a76", 	32x"1d63f975", 	32x"0e330a81", 	32x"fc588982", 
	32x"b21572c9", 	32x"407ef1ca", 	32x"532e023e", 	32x"a145813d", 
	32x"758fe5d6", 	32x"87e466d5", 	32x"94b49521", 	32x"66df1622", 
	32x"38cc2a06", 	32x"caa7a905", 	32x"d9f75af1", 	32x"2b9cd9f2", 
	32x"ff56bd19", 	32x"0d3d3e1a", 	32x"1e6dcdee", 	32x"ec064eed", 
	32x"c38d26c4", 	32x"31e6a5c7", 	32x"22b65633", 	32x"d0ddd530", 
	32x"0417b1db", 	32x"f67c32d8", 	32x"e52cc12c", 	32x"1747422f", 
	32x"49547e0b", 	32x"bb3ffd08", 	32x"a86f0efc", 	32x"5a048dff", 
	32x"8ecee914", 	32x"7ca56a17", 	32x"6ff599e3", 	32x"9d9e1ae0", 
	32x"d3d3e1ab", 	32x"21b862a8", 	32x"32e8915c", 	32x"c083125f", 
	32x"144976b4", 	32x"e622f5b7", 	32x"f5720643", 	32x"07198540", 
	32x"590ab964", 	32x"ab613a67", 	32x"b831c993", 	32x"4a5a4a90", 
	32x"9e902e7b", 	32x"6cfbad78", 	32x"7fab5e8c", 	32x"8dc0dd8f", 
	32x"e330a81a", 	32x"115b2b19", 	32x"020bd8ed", 	32x"f0605bee", 
	32x"24aa3f05", 	32x"d6c1bc06", 	32x"c5914ff2", 	32x"37faccf1", 
	32x"69e9f0d5", 	32x"9b8273d6", 	32x"88d28022", 	32x"7ab90321", 
	32x"ae7367ca", 	32x"5c18e4c9", 	32x"4f48173d", 	32x"bd23943e", 
	32x"f36e6f75", 	32x"0105ec76", 	32x"12551f82", 	32x"e03e9c81", 
	32x"34f4f86a", 	32x"c69f7b69", 	32x"d5cf889d", 	32x"27a40b9e", 
	32x"79b737ba", 	32x"8bdcb4b9", 	32x"988c474d", 	32x"6ae7c44e", 
	32x"be2da0a5", 	32x"4c4623a6", 	32x"5f16d052", 	32x"ad7d5351"
);



-- crc32c, polynomial 0x1edc6f41, 4 bits at once, reversed

constant crc32ctable4 : crc32table_t (0 to 2**4 - 1) := (
	32x"00000000", 	32x"105ec76f", 	32x"20bd8ede", 	32x"30e349b1", 
	32x"417b1dbc", 	32x"5125dad3", 	32x"61c69362", 	32x"7198540d", 
	32x"82f63b78", 	32x"92a8fc17", 	32x"a24bb5a6", 	32x"b21572c9", 
	32x"c38d26c4", 	32x"d3d3e1ab", 	32x"e330a81a", 	32x"f36e6f75"
);



-- crc32c, polynomial 0x1edc6f41, 2 bits at once, reversed

constant crc32ctable2 : crc32table_t (0 to 2**2 - 1) := (
	32x"00000000", 	32x"417b1dbc", 	32x"82f63b78", 	32x"c38d26c4"
);



-- crc32c, polynomial 0x1edc6f41, 1 bits at once, reversed

constant crc32ctable1 : crc32table_t (0 to 2**1 - 1) := (
	32x"00000000", 	32x"82f63b78"
);



-- crc32k, polynomial 0x741b8cd7, 8 bits at once, reversed

constant crc32ktable8 : crc32table_t (0 to 2**8 - 1) := (
	32x"00000000", 	32x"9695c4ca", 	32x"fb4839c9", 	32x"6dddfd03", 
	32x"20f3c3cf", 	32x"b6660705", 	32x"dbbbfa06", 	32x"4d2e3ecc", 
	32x"41e7879e", 	32x"d7724354", 	32x"baafbe57", 	32x"2c3a7a9d", 
	32x"61144451", 	32x"f781809b", 	32x"9a5c7d98", 	32x"0cc9b952", 
	32x"83cf0f3c", 	32x"155acbf6", 	32x"788736f5", 	32x"ee12f23f", 
	32x"a33cccf3", 	32x"35a90839", 	32x"5874f53a", 	32x"cee131f0", 
	32x"c22888a2", 	32x"54bd4c68", 	32x"3960b16b", 	32x"aff575a1", 
	32x"e2db4b6d", 	32x"744e8fa7", 	32x"199372a4", 	32x"8f06b66e", 
	32x"d1fdae25", 	32x"47686aef", 	32x"2ab597ec", 	32x"bc205326", 
	32x"f10e6dea", 	32x"679ba920", 	32x"0a465423", 	32x"9cd390e9", 
	32x"901a29bb", 	32x"068fed71", 	32x"6b521072", 	32x"fdc7d4b8", 
	32x"b0e9ea74", 	32x"267c2ebe", 	32x"4ba1d3bd", 	32x"dd341777", 
	32x"5232a119", 	32x"c4a765d3", 	32x"a97a98d0", 	32x"3fef5c1a", 
	32x"72c162d6", 	32x"e454a61c", 	32x"89895b1f", 	32x"1f1c9fd5", 
	32x"13d52687", 	32x"8540e24d", 	32x"e89d1f4e", 	32x"7e08db84", 
	32x"3326e548", 	32x"a5b32182", 	32x"c86edc81", 	32x"5efb184b", 
	32x"7598ec17", 	32x"e30d28dd", 	32x"8ed0d5de", 	32x"18451114", 
	32x"556b2fd8", 	32x"c3feeb12", 	32x"ae231611", 	32x"38b6d2db", 
	32x"347f6b89", 	32x"a2eaaf43", 	32x"cf375240", 	32x"59a2968a", 
	32x"148ca846", 	32x"82196c8c", 	32x"efc4918f", 	32x"79515545", 
	32x"f657e32b", 	32x"60c227e1", 	32x"0d1fdae2", 	32x"9b8a1e28", 
	32x"d6a420e4", 	32x"4031e42e", 	32x"2dec192d", 	32x"bb79dde7", 
	32x"b7b064b5", 	32x"2125a07f", 	32x"4cf85d7c", 	32x"da6d99b6", 
	32x"9743a77a", 	32x"01d663b0", 	32x"6c0b9eb3", 	32x"fa9e5a79", 
	32x"a4654232", 	32x"32f086f8", 	32x"5f2d7bfb", 	32x"c9b8bf31", 
	32x"849681fd", 	32x"12034537", 	32x"7fdeb834", 	32x"e94b7cfe", 
	32x"e582c5ac", 	32x"73170166", 	32x"1ecafc65", 	32x"885f38af", 
	32x"c5710663", 	32x"53e4c2a9", 	32x"3e393faa", 	32x"a8acfb60", 
	32x"27aa4d0e", 	32x"b13f89c4", 	32x"dce274c7", 	32x"4a77b00d", 
	32x"07598ec1", 	32x"91cc4a0b", 	32x"fc11b708", 	32x"6a8473c2", 
	32x"664dca90", 	32x"f0d80e5a", 	32x"9d05f359", 	32x"0b903793", 
	32x"46be095f", 	32x"d02bcd95", 	32x"bdf63096", 	32x"2b63f45c", 
	32x"eb31d82e", 	32x"7da41ce4", 	32x"1079e1e7", 	32x"86ec252d", 
	32x"cbc21be1", 	32x"5d57df2b", 	32x"308a2228", 	32x"a61fe6e2", 
	32x"aad65fb0", 	32x"3c439b7a", 	32x"519e6679", 	32x"c70ba2b3", 
	32x"8a259c7f", 	32x"1cb058b5", 	32x"716da5b6", 	32x"e7f8617c", 
	32x"68fed712", 	32x"fe6b13d8", 	32x"93b6eedb", 	32x"05232a11", 
	32x"480d14dd", 	32x"de98d017", 	32x"b3452d14", 	32x"25d0e9de", 
	32x"2919508c", 	32x"bf8c9446", 	32x"d2516945", 	32x"44c4ad8f", 
	32x"09ea9343", 	32x"9f7f5789", 	32x"f2a2aa8a", 	32x"64376e40", 
	32x"3acc760b", 	32x"ac59b2c1", 	32x"c1844fc2", 	32x"57118b08", 
	32x"1a3fb5c4", 	32x"8caa710e", 	32x"e1778c0d", 	32x"77e248c7", 
	32x"7b2bf195", 	32x"edbe355f", 	32x"8063c85c", 	32x"16f60c96", 
	32x"5bd8325a", 	32x"cd4df690", 	32x"a0900b93", 	32x"3605cf59", 
	32x"b9037937", 	32x"2f96bdfd", 	32x"424b40fe", 	32x"d4de8434", 
	32x"99f0baf8", 	32x"0f657e32", 	32x"62b88331", 	32x"f42d47fb", 
	32x"f8e4fea9", 	32x"6e713a63", 	32x"03acc760", 	32x"953903aa", 
	32x"d8173d66", 	32x"4e82f9ac", 	32x"235f04af", 	32x"b5cac065", 
	32x"9ea93439", 	32x"083cf0f3", 	32x"65e10df0", 	32x"f374c93a", 
	32x"be5af7f6", 	32x"28cf333c", 	32x"4512ce3f", 	32x"d3870af5", 
	32x"df4eb3a7", 	32x"49db776d", 	32x"24068a6e", 	32x"b2934ea4", 
	32x"ffbd7068", 	32x"6928b4a2", 	32x"04f549a1", 	32x"92608d6b", 
	32x"1d663b05", 	32x"8bf3ffcf", 	32x"e62e02cc", 	32x"70bbc606", 
	32x"3d95f8ca", 	32x"ab003c00", 	32x"c6ddc103", 	32x"504805c9", 
	32x"5c81bc9b", 	32x"ca147851", 	32x"a7c98552", 	32x"315c4198", 
	32x"7c727f54", 	32x"eae7bb9e", 	32x"873a469d", 	32x"11af8257", 
	32x"4f549a1c", 	32x"d9c15ed6", 	32x"b41ca3d5", 	32x"2289671f", 
	32x"6fa759d3", 	32x"f9329d19", 	32x"94ef601a", 	32x"027aa4d0", 
	32x"0eb31d82", 	32x"9826d948", 	32x"f5fb244b", 	32x"636ee081", 
	32x"2e40de4d", 	32x"b8d51a87", 	32x"d508e784", 	32x"439d234e", 
	32x"cc9b9520", 	32x"5a0e51ea", 	32x"37d3ace9", 	32x"a1466823", 
	32x"ec6856ef", 	32x"7afd9225", 	32x"17206f26", 	32x"81b5abec", 
	32x"8d7c12be", 	32x"1be9d674", 	32x"76342b77", 	32x"e0a1efbd", 
	32x"ad8fd171", 	32x"3b1a15bb", 	32x"56c7e8b8", 	32x"c0522c72"
);



-- crc32k, polynomial 0x741b8cd7, 4 bits at once, reversed

constant crc32ktable4 : crc32table_t (0 to 2**4 - 1) := (
	32x"00000000", 	32x"83cf0f3c", 	32x"d1fdae25", 	32x"5232a119", 
	32x"7598ec17", 	32x"f657e32b", 	32x"a4654232", 	32x"27aa4d0e", 
	32x"eb31d82e", 	32x"68fed712", 	32x"3acc760b", 	32x"b9037937", 
	32x"9ea93439", 	32x"1d663b05", 	32x"4f549a1c", 	32x"cc9b9520"
);



-- crc32k, polynomial 0x741b8cd7, 2 bits at once, reversed

constant crc32ktable2 : crc32table_t (0 to 2**2 - 1) := (
	32x"00000000", 	32x"7598ec17", 	32x"eb31d82e", 	32x"9ea93439"
);



-- crc32k, polynomial 0x741b8cd7, 1 bits at once, reversed

constant crc32ktable1 : crc32table_t (0 to 2**1 - 1) := (
	32x"00000000", 	32x"eb31d82e"
);



-- crc32k2, polynomial 0x32583499, 8 bits at once, reversed

constant crc32k2table8 : crc32table_t (0 to 2**8 - 1) := (
	32x"00000000", 	32x"ce3f0db3", 	32x"ae262fff", 	32x"6019224c", 
	32x"6e146b67", 	32x"a02b66d4", 	32x"c0324498", 	32x"0e0d492b", 
	32x"dc28d6ce", 	32x"1217db7d", 	32x"720ef931", 	32x"bc31f482", 
	32x"b23cbda9", 	32x"7c03b01a", 	32x"1c1a9256", 	32x"d2259fe5", 
	32x"8a099905", 	32x"443694b6", 	32x"242fb6fa", 	32x"ea10bb49", 
	32x"e41df262", 	32x"2a22ffd1", 	32x"4a3bdd9d", 	32x"8404d02e", 
	32x"56214fcb", 	32x"981e4278", 	32x"f8076034", 	32x"36386d87", 
	32x"383524ac", 	32x"f60a291f", 	32x"96130b53", 	32x"582c06e0", 
	32x"264b0693", 	32x"e8740b20", 	32x"886d296c", 	32x"465224df", 
	32x"485f6df4", 	32x"86606047", 	32x"e679420b", 	32x"28464fb8", 
	32x"fa63d05d", 	32x"345cddee", 	32x"5445ffa2", 	32x"9a7af211", 
	32x"9477bb3a", 	32x"5a48b689", 	32x"3a5194c5", 	32x"f46e9976", 
	32x"ac429f96", 	32x"627d9225", 	32x"0264b069", 	32x"cc5bbdda", 
	32x"c256f4f1", 	32x"0c69f942", 	32x"6c70db0e", 	32x"a24fd6bd", 
	32x"706a4958", 	32x"be5544eb", 	32x"de4c66a7", 	32x"10736b14", 
	32x"1e7e223f", 	32x"d0412f8c", 	32x"b0580dc0", 	32x"7e670073", 
	32x"4c960d26", 	32x"82a90095", 	32x"e2b022d9", 	32x"2c8f2f6a", 
	32x"22826641", 	32x"ecbd6bf2", 	32x"8ca449be", 	32x"429b440d", 
	32x"90bedbe8", 	32x"5e81d65b", 	32x"3e98f417", 	32x"f0a7f9a4", 
	32x"feaab08f", 	32x"3095bd3c", 	32x"508c9f70", 	32x"9eb392c3", 
	32x"c69f9423", 	32x"08a09990", 	32x"68b9bbdc", 	32x"a686b66f", 
	32x"a88bff44", 	32x"66b4f2f7", 	32x"06add0bb", 	32x"c892dd08", 
	32x"1ab742ed", 	32x"d4884f5e", 	32x"b4916d12", 	32x"7aae60a1", 
	32x"74a3298a", 	32x"ba9c2439", 	32x"da850675", 	32x"14ba0bc6", 
	32x"6add0bb5", 	32x"a4e20606", 	32x"c4fb244a", 	32x"0ac429f9", 
	32x"04c960d2", 	32x"caf66d61", 	32x"aaef4f2d", 	32x"64d0429e", 
	32x"b6f5dd7b", 	32x"78cad0c8", 	32x"18d3f284", 	32x"d6ecff37", 
	32x"d8e1b61c", 	32x"16debbaf", 	32x"76c799e3", 	32x"b8f89450", 
	32x"e0d492b0", 	32x"2eeb9f03", 	32x"4ef2bd4f", 	32x"80cdb0fc", 
	32x"8ec0f9d7", 	32x"40fff464", 	32x"20e6d628", 	32x"eed9db9b", 
	32x"3cfc447e", 	32x"f2c349cd", 	32x"92da6b81", 	32x"5ce56632", 
	32x"52e82f19", 	32x"9cd722aa", 	32x"fcce00e6", 	32x"32f10d55", 
	32x"992c1a4c", 	32x"571317ff", 	32x"370a35b3", 	32x"f9353800", 
	32x"f738712b", 	32x"39077c98", 	32x"591e5ed4", 	32x"97215367", 
	32x"4504cc82", 	32x"8b3bc131", 	32x"eb22e37d", 	32x"251deece", 
	32x"2b10a7e5", 	32x"e52faa56", 	32x"8536881a", 	32x"4b0985a9", 
	32x"13258349", 	32x"dd1a8efa", 	32x"bd03acb6", 	32x"733ca105", 
	32x"7d31e82e", 	32x"b30ee59d", 	32x"d317c7d1", 	32x"1d28ca62", 
	32x"cf0d5587", 	32x"01325834", 	32x"612b7a78", 	32x"af1477cb", 
	32x"a1193ee0", 	32x"6f263353", 	32x"0f3f111f", 	32x"c1001cac", 
	32x"bf671cdf", 	32x"7158116c", 	32x"11413320", 	32x"df7e3e93", 
	32x"d17377b8", 	32x"1f4c7a0b", 	32x"7f555847", 	32x"b16a55f4", 
	32x"634fca11", 	32x"ad70c7a2", 	32x"cd69e5ee", 	32x"0356e85d", 
	32x"0d5ba176", 	32x"c364acc5", 	32x"a37d8e89", 	32x"6d42833a", 
	32x"356e85da", 	32x"fb518869", 	32x"9b48aa25", 	32x"5577a796", 
	32x"5b7aeebd", 	32x"9545e30e", 	32x"f55cc142", 	32x"3b63ccf1", 
	32x"e9465314", 	32x"27795ea7", 	32x"47607ceb", 	32x"895f7158", 
	32x"87523873", 	32x"496d35c0", 	32x"2974178c", 	32x"e74b1a3f", 
	32x"d5ba176a", 	32x"1b851ad9", 	32x"7b9c3895", 	32x"b5a33526", 
	32x"bbae7c0d", 	32x"759171be", 	32x"158853f2", 	32x"dbb75e41", 
	32x"0992c1a4", 	32x"c7adcc17", 	32x"a7b4ee5b", 	32x"698be3e8", 
	32x"6786aac3", 	32x"a9b9a770", 	32x"c9a0853c", 	32x"079f888f", 
	32x"5fb38e6f", 	32x"918c83dc", 	32x"f195a190", 	32x"3faaac23", 
	32x"31a7e508", 	32x"ff98e8bb", 	32x"9f81caf7", 	32x"51bec744", 
	32x"839b58a1", 	32x"4da45512", 	32x"2dbd775e", 	32x"e3827aed", 
	32x"ed8f33c6", 	32x"23b03e75", 	32x"43a91c39", 	32x"8d96118a", 
	32x"f3f111f9", 	32x"3dce1c4a", 	32x"5dd73e06", 	32x"93e833b5", 
	32x"9de57a9e", 	32x"53da772d", 	32x"33c35561", 	32x"fdfc58d2", 
	32x"2fd9c737", 	32x"e1e6ca84", 	32x"81ffe8c8", 	32x"4fc0e57b", 
	32x"41cdac50", 	32x"8ff2a1e3", 	32x"efeb83af", 	32x"21d48e1c", 
	32x"79f888fc", 	32x"b7c7854f", 	32x"d7dea703", 	32x"19e1aab0", 
	32x"17ece39b", 	32x"d9d3ee28", 	32x"b9cacc64", 	32x"77f5c1d7", 
	32x"a5d05e32", 	32x"6bef5381", 	32x"0bf671cd", 	32x"c5c97c7e", 
	32x"cbc43555", 	32x"05fb38e6", 	32x"65e21aaa", 	32x"abdd1719"
);



-- crc32k2, polynomial 0x32583499, 4 bits at once, reversed

constant crc32k2table4 : crc32table_t (0 to 2**4 - 1) := (
	32x"00000000", 	32x"8a099905", 	32x"264b0693", 	32x"ac429f96", 
	32x"4c960d26", 	32x"c69f9423", 	32x"6add0bb5", 	32x"e0d492b0", 
	32x"992c1a4c", 	32x"13258349", 	32x"bf671cdf", 	32x"356e85da", 
	32x"d5ba176a", 	32x"5fb38e6f", 	32x"f3f111f9", 	32x"79f888fc"
);



-- crc32k2, polynomial 0x32583499, 2 bits at once, reversed

constant crc32k2table2 : crc32table_t (0 to 2**2 - 1) := (
	32x"00000000", 	32x"4c960d26", 	32x"992c1a4c", 	32x"d5ba176a"
);



-- crc32k2, polynomial 0x32583499, 1 bits at once, reversed

constant crc32k2table1 : crc32table_t (0 to 2**1 - 1) := (
	32x"00000000", 	32x"992c1a4c"
);



-- crc32q, polynomial 0x814141ab, 8 bits at once, reversed

constant crc32qtable8 : crc32table_t (0 to 2**8 - 1) := (
	32x"00000000", 	32x"999a0002", 	32x"98310507", 	32x"01ab0505", 
	32x"9b670f0d", 	32x"02fd0f0f", 	32x"03560a0a", 	32x"9acc0a08", 
	32x"9dcb1b19", 	32x"04511b1b", 	32x"05fa1e1e", 	32x"9c601e1c", 
	32x"06ac1414", 	32x"9f361416", 	32x"9e9d1113", 	32x"07071111", 
	32x"90933331", 	32x"09093333", 	32x"08a23636", 	32x"91383634", 
	32x"0bf43c3c", 	32x"926e3c3e", 	32x"93c5393b", 	32x"0a5f3939", 
	32x"0d582828", 	32x"94c2282a", 	32x"95692d2f", 	32x"0cf32d2d", 
	32x"963f2725", 	32x"0fa52727", 	32x"0e0e2222", 	32x"97942220", 
	32x"8a236361", 	32x"13b96363", 	32x"12126666", 	32x"8b886664", 
	32x"11446c6c", 	32x"88de6c6e", 	32x"8975696b", 	32x"10ef6969", 
	32x"17e87878", 	32x"8e72787a", 	32x"8fd97d7f", 	32x"16437d7d", 
	32x"8c8f7775", 	32x"15157777", 	32x"14be7272", 	32x"8d247270", 
	32x"1ab05050", 	32x"832a5052", 	32x"82815557", 	32x"1b1b5555", 
	32x"81d75f5d", 	32x"184d5f5f", 	32x"19e65a5a", 	32x"807c5a58", 
	32x"877b4b49", 	32x"1ee14b4b", 	32x"1f4a4e4e", 	32x"86d04e4c", 
	32x"1c1c4444", 	32x"85864446", 	32x"842d4143", 	32x"1db74141", 
	32x"bf43c3c1", 	32x"26d9c3c3", 	32x"2772c6c6", 	32x"bee8c6c4", 
	32x"2424cccc", 	32x"bdbeccce", 	32x"bc15c9cb", 	32x"258fc9c9", 
	32x"2288d8d8", 	32x"bb12d8da", 	32x"bab9dddf", 	32x"2323dddd", 
	32x"b9efd7d5", 	32x"2075d7d7", 	32x"21ded2d2", 	32x"b844d2d0", 
	32x"2fd0f0f0", 	32x"b64af0f2", 	32x"b7e1f5f7", 	32x"2e7bf5f5", 
	32x"b4b7fffd", 	32x"2d2dffff", 	32x"2c86fafa", 	32x"b51cfaf8", 
	32x"b21bebe9", 	32x"2b81ebeb", 	32x"2a2aeeee", 	32x"b3b0eeec", 
	32x"297ce4e4", 	32x"b0e6e4e6", 	32x"b14de1e3", 	32x"28d7e1e1", 
	32x"3560a0a0", 	32x"acfaa0a2", 	32x"ad51a5a7", 	32x"34cba5a5", 
	32x"ae07afad", 	32x"379dafaf", 	32x"3636aaaa", 	32x"afacaaa8", 
	32x"a8abbbb9", 	32x"3131bbbb", 	32x"309abebe", 	32x"a900bebc", 
	32x"33ccb4b4", 	32x"aa56b4b6", 	32x"abfdb1b3", 	32x"3267b1b1", 
	32x"a5f39391", 	32x"3c699393", 	32x"3dc29696", 	32x"a4589694", 
	32x"3e949c9c", 	32x"a70e9c9e", 	32x"a6a5999b", 	32x"3f3f9999", 
	32x"38388888", 	32x"a1a2888a", 	32x"a0098d8f", 	32x"39938d8d", 
	32x"a35f8785", 	32x"3ac58787", 	32x"3b6e8282", 	32x"a2f48280", 
	32x"d5828281", 	32x"4c188283", 	32x"4db38786", 	32x"d4298784", 
	32x"4ee58d8c", 	32x"d77f8d8e", 	32x"d6d4888b", 	32x"4f4e8889", 
	32x"48499998", 	32x"d1d3999a", 	32x"d0789c9f", 	32x"49e29c9d", 
	32x"d32e9695", 	32x"4ab49697", 	32x"4b1f9392", 	32x"d2859390", 
	32x"4511b1b0", 	32x"dc8bb1b2", 	32x"dd20b4b7", 	32x"44bab4b5", 
	32x"de76bebd", 	32x"47ecbebf", 	32x"4647bbba", 	32x"dfddbbb8", 
	32x"d8daaaa9", 	32x"4140aaab", 	32x"40ebafae", 	32x"d971afac", 
	32x"43bda5a4", 	32x"da27a5a6", 	32x"db8ca0a3", 	32x"4216a0a1", 
	32x"5fa1e1e0", 	32x"c63be1e2", 	32x"c790e4e7", 	32x"5e0ae4e5", 
	32x"c4c6eeed", 	32x"5d5ceeef", 	32x"5cf7ebea", 	32x"c56debe8", 
	32x"c26afaf9", 	32x"5bf0fafb", 	32x"5a5bfffe", 	32x"c3c1fffc", 
	32x"590df5f4", 	32x"c097f5f6", 	32x"c13cf0f3", 	32x"58a6f0f1", 
	32x"cf32d2d1", 	32x"56a8d2d3", 	32x"5703d7d6", 	32x"ce99d7d4", 
	32x"5455dddc", 	32x"cdcfddde", 	32x"cc64d8db", 	32x"55fed8d9", 
	32x"52f9c9c8", 	32x"cb63c9ca", 	32x"cac8cccf", 	32x"5352cccd", 
	32x"c99ec6c5", 	32x"5004c6c7", 	32x"51afc3c2", 	32x"c835c3c0", 
	32x"6ac14140", 	32x"f35b4142", 	32x"f2f04447", 	32x"6b6a4445", 
	32x"f1a64e4d", 	32x"683c4e4f", 	32x"69974b4a", 	32x"f00d4b48", 
	32x"f70a5a59", 	32x"6e905a5b", 	32x"6f3b5f5e", 	32x"f6a15f5c", 
	32x"6c6d5554", 	32x"f5f75556", 	32x"f45c5053", 	32x"6dc65051", 
	32x"fa527271", 	32x"63c87273", 	32x"62637776", 	32x"fbf97774", 
	32x"61357d7c", 	32x"f8af7d7e", 	32x"f904787b", 	32x"609e7879", 
	32x"67996968", 	32x"fe03696a", 	32x"ffa86c6f", 	32x"66326c6d", 
	32x"fcfe6665", 	32x"65646667", 	32x"64cf6362", 	32x"fd556360", 
	32x"e0e22221", 	32x"79782223", 	32x"78d32726", 	32x"e1492724", 
	32x"7b852d2c", 	32x"e21f2d2e", 	32x"e3b4282b", 	32x"7a2e2829", 
	32x"7d293938", 	32x"e4b3393a", 	32x"e5183c3f", 	32x"7c823c3d", 
	32x"e64e3635", 	32x"7fd43637", 	32x"7e7f3332", 	32x"e7e53330", 
	32x"70711110", 	32x"e9eb1112", 	32x"e8401417", 	32x"71da1415", 
	32x"eb161e1d", 	32x"728c1e1f", 	32x"73271b1a", 	32x"eabd1b18", 
	32x"edba0a09", 	32x"74200a0b", 	32x"758b0f0e", 	32x"ec110f0c", 
	32x"76dd0504", 	32x"ef470506", 	32x"eeec0003", 	32x"77760001"
);



-- crc32q, polynomial 0x814141ab, 4 bits at once, reversed

constant crc32qtable4 : crc32table_t (0 to 2**4 - 1) := (
	32x"00000000", 	32x"90933331", 	32x"8a236361", 	32x"1ab05050", 
	32x"bf43c3c1", 	32x"2fd0f0f0", 	32x"3560a0a0", 	32x"a5f39391", 
	32x"d5828281", 	32x"4511b1b0", 	32x"5fa1e1e0", 	32x"cf32d2d1", 
	32x"6ac14140", 	32x"fa527271", 	32x"e0e22221", 	32x"70711110"
);



-- crc32q, polynomial 0x814141ab, 2 bits at once, reversed

constant crc32qtable2 : crc32table_t (0 to 2**2 - 1) := (
	32x"00000000", 	32x"bf43c3c1", 	32x"d5828281", 	32x"6ac14140"
);



-- crc32q, polynomial 0x814141ab, 1 bits at once, reversed

constant crc32qtable1 : crc32table_t (0 to 2**1 - 1) := (
	32x"00000000", 	32x"d5828281"
);


end package;
