#! /sbin/sh
#@(#) node_list This program  send request to the webmaster
#@(#) node_list (c) Sergey Sinyagov, sinyagov@mail.com
#@(#) node_list (c) Sergey Sinyagov, (301) 236-8255 ,sergey.a.sinyagov@bellatlantic.com


#################### Main ###############
cat << EOF





<html>
<body>
Query submitted, check the data: <br>

`echo "$QUERY_STRING"|
sed '
	s/%40/@/g
	s/%2C/,/g
	s/+/ /g
'|awk '{ n=split($0,a,"&");for(i=1;i<=n;i++) print a[i],"<br>" }'`
</body>
</html>
EOF

cat <<EOF1 |mailx -s "WEB:New User Request" dennis.f.sennikovskiy@verizon.com

Dear Dennis!

Could You open me access to the DPO Documentation website (dpo.verizon.com), please!

My personal data is:

`echo "$QUERY_STRING"|
sed '
	s/%40/@/g
	s/%2C/,/g
	s/+/ /g
'|awk '{ 
	n=split($0,a,"&")
	for(i=1;i<=n;i++) {
		split(a[i],b,"=")
		if( b[1] ~ /^APPL/ || b[1] ~ /^Other/ )
			appl=sprintf("%s%s,",appl,b[2])
		else
			print a[i] 
	}
}
END { 
	print "APPLICATIONS=",appl 
} '`

Thanks a lot,
Your web future user
EOF1
exit
