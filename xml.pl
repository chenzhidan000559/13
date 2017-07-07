＃！/ usr / bin / perl
使用 XML :: DOM;
我的（$ mu_lu，$ mudi_lu）;
我的 $ ssh_kou = 22;
我的（$ game_src，$ game_md5，$ game_config，$ server_game_src，$ game_cmdb）;
我的 $ game_flag = “ ./tb.xml ” ;
我的 $ type = $ ARGV [0];

＃输入判断
if（！$ ARGV [0]）{ print  “用法：$ 0 game_flag ipaddress \ n ” ; 退出 };
$ null_flag = “ tongbu_flag = ”。“ \” “。” $ {ARGV [0]} “。” \“ ” ;
＃ {print err; exit;} except（$ a = qx＃grep'$ null_flag'$ game_flag＃）;
除非（$ a = qx＃ grep' $ null_flag ' $ game_flag ＃）{ print   “ err game_name请检查tb.xml \ n ” ; 退出 ;}


＃　XML分析
sub  ipt_xml（）
{
我的 $ flag =（）;
我的 $ parser = new XML :: DOM :: Parser;
我的 $ doc = $ parser - > parsefile（“ $ game_flag ”）;
我的 $ nodes = $ doc - > getElementsByTagName（“ tongbu ”）;
我的 $ n = $ nodes - > getLength;
我的 ％ipt_hash ;

for（my  $ i = 0; $ i < $ n ; $ i ++）
 {
     我的 $ node = $ nodes - > item（$ i）;                                                    
     我的 $ tongbu_flag   = $ node - > getAttribute（“ tongbu_flag ”）;
     打印 “ $ type \ n ” ;    
     打印 “ $ tongbu_flag \ n ” ;
     
     if（$ tongbu_flag  eq  $ type）
                  {   print  “ ok \ n ” ;
		     $ game_src = $ node - > getAttribute（“ game_src ”）;
		     $ game_md5 = $ node - > getAttribute（“ game_md5 ”）;
		     $ game_config      = $ node - > getAttribute（“ game_config ”）;
		     $ server_game_src = $ node - > getAttribute（“ server_game_src ”）;
		     $ game_cmdb = $ node - > getAttribute（“ game_cmdb ”）;
		     push   （@mu_lu，（$ game_src，$ game_config，$ game_md5））;                             
		     push   （@mudi_lu，（$ server_game_src，$ game_config，$ server_game_src））;                             
                  }
     ＃否则{退出;}
 }
}
ipt_xml（）;





＃ #### #########
＃ ####老rsync.pl #########
＃ #### #########

＃   单服务器同步xml.pl kof 10.1.1.1
＃
我的 $ datea = qx＃ date“+ ％F - ％T ” ＃ ;  
我的 $ totala = $＃mu_lu +1;
＃ qx＃cp -r $ mu_lu [1] / export / config_bak / ahlm2 / config $ datea＃;

if（@ARGV == 2）{
打印 “ dddddddddddddddddd \ n ” ;
我的 $ jin_xing_zhonga = qx＃ ssh -p $ ssh_kou  $ ARGV [1] hostname ＃ ;
qx＃ cd $ mu_lu [0]; find ./ -type f -print0 | xargs -0 md5sum> $ mu_lu [2] ＃ ;
print  “正在进行$ jin_xing_zhonga .... \ n ” ;
我的 $ iii = 0;
   对于（` SEQ $总量a `）
   {
   qx＃ / usr / bin / rsync -azve“ssh -p $ ssh_kou ”--delete --bwlimit 1000 $ mu_lu [ $ iii ] root \ @ $ ARGV [1]：$ mudi_lu [ $ iii ] ＃ ;
   打印 “ $ mu_lu [ $ iii ] ---->   $ mudi_lu [ $ uuu ] \ n ” ;
   $ iii + = 1;
   }
打印 “ =============开始检查MD5 ============= \ n ” ;

system（“ echo ============== ssh -p $ ssh_kou  $ ARGV [1] hostname`; ssh $ ARGV [1] \” cd $ {server_game_src} ; md5sum -c。 / $ {game_md5} | grep -iv ok \“ ”）;
system（“ echo ==`ssh -p $ ssh_kou  $ ARGV [1] cat $ {server_game_src} / version` ”）;
打印 “ ============= MD5检查完毕============= \ n ” ;
退出 0;
}


＃多服务器同步xml.pl kof
＃
我 @ip ;
@ip = ` cat $ {game_config} /ipxml.conf | awk'{print \ $ 1}' ` ;
qx＃ cd $ mu_lu [0]; find ./ -type f -print0 | xargs -0 md5sum> $ mu_lu [2] ＃ ;
我的 $ total = $＃ip +1;
我的 $ num = $ total ;
我的 $ a = 0;
我的 $ bam = 0;

$ SIG { CHLD } = sub { $ a - ; $ bam ++};

我的 ％PID ;

而（$ total）
{
 如果（$ a <20）
  {
   我的 $ pid = fork（）;
   $ pid { $ pid } = 1;
   if（$ pid == 0）
    {
      我的 $ de = $ num - $ total ;
      $ IP [ $ DE ] =〜小号 / \ n // 克 ;
      我的 $ jin_xing_zhong = qx＃ ssh -p $ ssh_kou  $ ip [ $ de ] hostname ＃ ;
      print  “正在进行$ jin_xing_zhong .... \ n ” ;
      我的 $ ii = 0;
        对于（` SEQ $总量a `）
        {
        qx＃ / usr / bin / rsync -azve“ssh -p $ ssh_kou ”--delete --bwlimit 1000 $ mu_lu [ $ ii ] root \ @ $ ip [ $ de ]：$ mudi_lu [ $ ii ]> / dev /空＃ ;
        $ ii + = 1;
        }
      退出 0;
    }
   $ a ++;
   $ total - ;
   } 
  while（$ bam > 0）
   {
     while（我的 $ exit_pid = waitpid（-1，WNOHANG）> 0）
      {
        $ bam - ;
        if（exists（$ pid { $ exit_pid }））{ delete  $ pid { $ exit_pid };}
      }
   }
}

我的 @left = keys  ％pid ;
if（@left）
 {
   foreach  我的 $ j（@left）
    {
        waitpid（$ j，0）;
    }
 }
打印 “ ==============同步已结束\ n ” ;
打印 “ =============请去rundeck检查”检查同步MD5“============= \ n ” ;
打印 “ =============请去rundeck检查”检查同步MD5“============= \ n ” ;




＃ ######## XML文件配置示例##################
=切
<？xml version = “ 1.0 ” encoding = “ utf-8 ”？>
<DATAS>
“tongbu tongbu_flag = ” kof “   game_src = ” / export / new_fabu_server / kof_app_server / rsync / 1 “   game_config = ” / export / cmdb / new / kof_dalu / kof_dalu / ios / shangxian “ game_md5 = ” fabu.md5 “   game_cmdb = ” cmdb_kof “   server_game_src = ” / home / super / update / kofyypackage / srcfiles “   server_game_conf = ” / home / super / update / kofyypackage / config “ />
“tongbu tongbu_flag = ”和“   game_src = ” / export / new_fabu_server / kof_app_server / rsync / 2 “   game_config = ” / export / cmdb / new / kof_dalu / kof_dalu / ios / shangxian “ game_md5 = ” fabu.md5 “   game_cmdb = ” cmdb_and “   server_game_src = ” / home / super / update / kofyypackage / srcfiles “   server_game_conf = ” / home / super / update / kofyypackage / config “ />
</ DATAS>
=切
