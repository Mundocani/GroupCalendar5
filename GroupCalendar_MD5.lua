-- An MD5 mplementation in Lua, requires bitlib
-- Written by Jean-Claude Wippler
-- 10/02/2001 jcw@equi4.com
-- Original source available at http://www.equi4.com/md5/md5calc.lua

-- Transformed for use in Group Calendar by John Stephen

GroupCalendar._MD5 = {}

GroupCalendar._MD5.Mask32 = tonumber("ffffffff", 16)
GroupCalendar._MD5.Consts =
{
	"d76aa478", "e8c7b756", "242070db", "c1bdceee",
	"f57c0faf", "4787c62a", "a8304613", "fd469501",
	"698098d8", "8b44f7af", "ffff5bb1", "895cd7be",
	"6b901122", "fd987193", "a679438e", "49b40821",
	
	"f61e2562", "c040b340", "265e5a51", "e9b6c7aa",
	"d62f105d", "02441453", "d8a1e681", "e7d3fbc8",
	"21e1cde6", "c33707d6", "f4d50d87", "455a14ed",
	"a9e3e905", "fcefa3f8", "676f02d9", "8d2a4c8a",
	
	"fffa3942", "8771f681", "6d9d6122", "fde5380c",
	"a4beea44", "4bdecfa9", "f6bb4b60", "bebfbc70",
	"289b7ec6", "eaa127fa", "d4ef3085", "04881d05",
	"d9d4d039", "e6db99e5", "1fa27cf8", "c4ac5665",
	
	"f4292244", "432aff97", "ab9423a7", "fc93a039",
	"655b59c3", "8f0ccc92", "ffeff47d", "85845dd1",
	"6fa87e4f", "fe2ce6e0", "a3014314", "4e0811a1",
	"f7537e82", "bd3af235", "2ad7d2bb", "eb86d391",
	
	"67452301", "efcdab89", "98badcfe", "10325476",
}

for vIndex, vConstStr in ipairs(GroupCalendar._MD5.Consts) do
	GroupCalendar._MD5.Consts[vIndex] = tonumber(vConstStr, 16)
end

function GroupCalendar._MD5:Construct()
end

function GroupCalendar._MD5.f(x, y, z)
	return bit.bor(bit.band(x, y), bit.band(-x - 1, z))
end

function GroupCalendar._MD5.g(x, y, z)
	return bit.bor(bit.band(x, z), bit.band(y, -z - 1))
end

function GroupCalendar._MD5.h(x, y, z)
	return bit.bxor(x, bit.bxor(y, z))
end

function GroupCalendar._MD5.i(x, y, z)
	return bit.bxor(y, bit.bor(x, -z - 1))
end

function GroupCalendar._MD5:z(f,a,b,c,d,x,s,ac)
	a = bit.band(a + f(b, c, d) + x + ac, self.Mask32)
	
	-- be *very* careful that left shift does not cause rounding!
	
	return bit.bor(bit.lshift(bit.band(a, bit.rshift(self.Mask32, s)), s), bit.rshift(a, 32 - s)) + b
end

function GroupCalendar._MD5:Transform(A,B,C,D,X)
	local a, b, c, d = A, B, C, D
	local t = self.Consts
	
	-- Round 1
	
	a=self:z(self.f,a,b,c,d,X[ 1], 7,t[ 1])
	d=self:z(self.f,d,a,b,c,X[ 2],12,t[ 2])
	c=self:z(self.f,c,d,a,b,X[ 3],17,t[ 3])
	b=self:z(self.f,b,c,d,a,X[ 4],22,t[ 4])
	a=self:z(self.f,a,b,c,d,X[ 5], 7,t[ 5])
	d=self:z(self.f,d,a,b,c,X[ 6],12,t[ 6])
	c=self:z(self.f,c,d,a,b,X[ 7],17,t[ 7])
	b=self:z(self.f,b,c,d,a,X[ 8],22,t[ 8])
	a=self:z(self.f,a,b,c,d,X[ 9], 7,t[ 9])
	d=self:z(self.f,d,a,b,c,X[10],12,t[10])
	c=self:z(self.f,c,d,a,b,X[11],17,t[11])
	b=self:z(self.f,b,c,d,a,X[12],22,t[12])
	a=self:z(self.f,a,b,c,d,X[13], 7,t[13])
	d=self:z(self.f,d,a,b,c,X[14],12,t[14])
	c=self:z(self.f,c,d,a,b,X[15],17,t[15])
	b=self:z(self.f,b,c,d,a,X[16],22,t[16])
	
	-- Round 2
	
	a=self:z(self.g,a,b,c,d,X[ 2], 5,t[17])
	d=self:z(self.g,d,a,b,c,X[ 7], 9,t[18])
	c=self:z(self.g,c,d,a,b,X[12],14,t[19])
	b=self:z(self.g,b,c,d,a,X[ 1],20,t[20])
	a=self:z(self.g,a,b,c,d,X[ 6], 5,t[21])
	d=self:z(self.g,d,a,b,c,X[11], 9,t[22])
	c=self:z(self.g,c,d,a,b,X[16],14,t[23])
	b=self:z(self.g,b,c,d,a,X[ 5],20,t[24])
	a=self:z(self.g,a,b,c,d,X[10], 5,t[25])
	d=self:z(self.g,d,a,b,c,X[15], 9,t[26])
	c=self:z(self.g,c,d,a,b,X[ 4],14,t[27])
	b=self:z(self.g,b,c,d,a,X[ 9],20,t[28])
	a=self:z(self.g,a,b,c,d,X[14], 5,t[29])
	d=self:z(self.g,d,a,b,c,X[ 3], 9,t[30])
	c=self:z(self.g,c,d,a,b,X[ 8],14,t[31])
	b=self:z(self.g,b,c,d,a,X[13],20,t[32])
	
	-- Round 3
	
	a=self:z(self.h,a,b,c,d,X[ 6], 4,t[33])
	d=self:z(self.h,d,a,b,c,X[ 9],11,t[34])
	c=self:z(self.h,c,d,a,b,X[12],16,t[35])
	b=self:z(self.h,b,c,d,a,X[15],23,t[36])
	a=self:z(self.h,a,b,c,d,X[ 2], 4,t[37])
	d=self:z(self.h,d,a,b,c,X[ 5],11,t[38])
	c=self:z(self.h,c,d,a,b,X[ 8],16,t[39])
	b=self:z(self.h,b,c,d,a,X[11],23,t[40])
	a=self:z(self.h,a,b,c,d,X[14], 4,t[41])
	d=self:z(self.h,d,a,b,c,X[ 1],11,t[42])
	c=self:z(self.h,c,d,a,b,X[ 4],16,t[43])
	b=self:z(self.h,b,c,d,a,X[ 7],23,t[44])
	a=self:z(self.h,a,b,c,d,X[10], 4,t[45])
	d=self:z(self.h,d,a,b,c,X[13],11,t[46])
	c=self:z(self.h,c,d,a,b,X[16],16,t[47])
	b=self:z(self.h,b,c,d,a,X[ 3],23,t[48])
	
	-- Round 4
	
	a=self:z(self.i,a,b,c,d,X[ 1], 6,t[49])
	d=self:z(self.i,d,a,b,c,X[ 8],10,t[50])
	c=self:z(self.i,c,d,a,b,X[15],15,t[51])
	b=self:z(self.i,b,c,d,a,X[ 6],21,t[52])
	a=self:z(self.i,a,b,c,d,X[13], 6,t[53])
	d=self:z(self.i,d,a,b,c,X[ 4],10,t[54])
	c=self:z(self.i,c,d,a,b,X[11],15,t[55])
	b=self:z(self.i,b,c,d,a,X[ 2],21,t[56])
	a=self:z(self.i,a,b,c,d,X[ 9], 6,t[57])
	d=self:z(self.i,d,a,b,c,X[16],10,t[58])
	c=self:z(self.i,c,d,a,b,X[ 7],15,t[59])
	b=self:z(self.i,b,c,d,a,X[14],21,t[60])
	a=self:z(self.i,a,b,c,d,X[ 5], 6,t[61])
	d=self:z(self.i,d,a,b,c,X[12],10,t[62])
	c=self:z(self.i,c,d,a,b,X[ 3],15,t[63])
	b=self:z(self.i,b,c,d,a,X[10],21,t[64])

	return bit.band(A+a, self.Mask32),
	       bit.band(B+b, self.Mask32),
	       bit.band(C+c, self.Mask32),
	       bit.band(D+d, self.Mask32)
end

function GroupCalendar._MD5:Calc(pString)
	self:BeginDigest()
	self:DigestString(pString)
	return self:EndDigest()
end

function GroupCalendar._MD5:BeginDigest()
	self.CurMessage = ""
	self.CurLen = 0
	self.TotalLen = 0
	
	self.a = self.Consts[65]
	self.b = self.Consts[66]
	self.c = self.Consts[67]
	self.d = self.Consts[68]
end

function GroupCalendar._MD5:DigestString(pString)
	local vStringLen = string.len(pString)
	
	self.CurMessage = self.CurMessage..pString
	self.CurLen = self.CurLen + vStringLen
	self.TotalLen = self.TotalLen + vStringLen
	
	local vIndex = 1
	
	while self.CurLen >= 64 do
		self.a, self.b, self.c, self.d =
			self:Transform(
				self.a, self.b, self.c, self.d,
				self.SliceStringToLEs(string.sub(self.CurMessage, vIndex, vIndex + 63)))
		
		vIndex = vIndex + 64
		self.CurLen = self.CurLen - 64
	end
	
	self.CurMessage = string.sub(self.CurMessage, -self.CurLen)
end

function GroupCalendar._MD5:EndDigest()
	local vPadLength = 56 - self.CurLen
	
	if self.CurLen > 56 then
		vPadLength = vPadLength + 64
	
	elseif vPadLength == 0 then
		vPadLength = 64
	end
	
	self:DigestString(
			strchar(128)..strrep(strchar(0), vPadLength - 1)..
			self.LEToString(8 * self.TotalLen)..self.LEToString(0))
	
	local vResult = format(
						"%08x%08x%08x%08x",
						self.swap(self.a),
						self.swap(self.b),
						self.swap(self.c),
						self.swap(self.d))
	
	-- Erase our tracks (enable this if ever used for encrytpion purposes)
	--[[
	self.CurMessage = nil
	self.CurLen = nil
	self.TotalLen = nil
	
	self.a = nil
	self.b = nil
	self.c = nil
	self.d = nil
	]]--
	--
	
	return vResult
end

function GroupCalendar._MD5.swap(w)
	local vResult = GroupCalendar._MD5.StringToBE4(GroupCalendar._MD5.LEToString(w))
	-- WoW Patch 5 doesn't allow unsigned 32-bit numbers in formatting, so convert it to signed
	if vResult > 2147483647 then vResult = vResult - 4294967296 end
	return vResult
end

-- convert little-endian 32-bit int to a 4-char string

function GroupCalendar._MD5.LEToString(i)
	i = math.floor(i)
	
	local f = function (s) return strchar(bit.band(bit.rshift(i,s),255)) end
	
	return f(0)..f(8)..f(16)..f(24)
end

-- convert raw string to big-endian int

function GroupCalendar._MD5.StringToBE4(str)
	return 256 * (256 * (256 * strbyte(str, 1) + strbyte(str, 2)) + strbyte(str, 3)) + strbyte(str, 4)
end

-- cut up a string in little-endian ints of given size

function GroupCalendar._MD5.SliceStringToLEs(s)
	local r = {}
	local o = 1
	
	for i = 1, 16 do
		local str = strsub(s, o, o + 3)
		r[i] = 256 * (256 * (256 * strbyte(str, 4) + strbyte(str, 3)) + strbyte(str, 2)) + strbyte(str, 1)
		o = o + 4
	end
	
	return r
end

function GroupCalendar._MD5:Verify()
	s0 = 'message digest'
	s1 = 'abcdefghijklmnopqrstuvwxyz'
	s2 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
	s3 = '12345678901234567890123456789012345678901234567890123456789012345678901234567890'
	
	if self:Calc('') ~= 'd41d8cd98f00b204e9800998ecf8427e' then
		GroupCalendar:ErrorMessage("MD5: Test 1 failed")
		return
	end
	
	if self:Calc('a') ~= '0cc175b9c0f1b6a831c399e269772661' then
		GroupCalendar:ErrorMessage("MD5 test 2 failed")
		return
	end
	
	if self:Calc('abc') ~= '900150983cd24fb0d6963f7d28e17f72' then
		GroupCalendar:ErrorMessage("MD5 test 3 failed")
		return
	end
	
	if self:Calc(s0) ~= 'f96b697d7cb7938d525a2f31aaf161d0' then
		GroupCalendar:ErrorMessage("MD5 test 4 failed")
		return
	end
	
	if self:Calc(s1) ~= 'c3fcd3d76192e4007dfb496cca67e13b' then
		GroupCalendar:ErrorMessage("MD5 test 5 failed")
		return
	end
	
	if self:Calc(s2) ~= 'd174ab98d277d9f5a5611c2c9f419d9f' then
		GroupCalendar:ErrorMessage("MD5 test 6 failed")
		return
	end
	
	if self:Calc(s3) ~= '57edf4a22be3c955ac49da2e2107b67a' then
		GroupCalendar:ErrorMessage("MD5 test 7 failed")
		return
	end
	
	GroupCalendar:NoteMessage("MD5: All tests passed")
end

function GroupCalendar._MD5:CheckPerformance()
	local vSizes = {10, 50, 100, 500, 1000, 5000, 10000}
	
	for _, vSize in ipairs(sizes) do
		local vString = strrep(' ', vSize)
		
		debugprofilestart()
		
		for j = 1, 10 do
			self:Calc(vString)
		end
		
		local vElapsed = math.floor(debugprofilestop() / 10)
		
		GroupCalendar:NoteMessage("%6d bytes: %4d ms", vSize, vElapsed)
	end
end
