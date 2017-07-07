#!/usr/bin/python
#encoding:utf-8
import sys,time,os 
import subprocess  
from optparse import OptionParser  
import xml.etree.ElementTree as ET
import threading

# 备份时间
bk_time=time.strftime('%Y%m%d%H%M%S', time.gmtime())

# 脚本调用游戏标识   ex: ./tb.py kof   
game_select=sys.argv[1]


# xml 解析取相应结果信息
def return_xml_mark(game_select):
    tree = ET.parse('tb.xml')
    root = tree.getroot()
    for games in root.findall('games'):  
        if games.get('name') == game_select:
            list      = games.find('list')
            md5_file  = games.find('md5_file')
            src_dir   = games.find('src_dir')
            dest_dir  = games.find('dest_dir')
            conf_dir  = games.find('conf_dir')
            rsync_opt = games.find('rsync_opt')
            return (list.text,md5_file.text,src_dir.text,dest_dir.text,conf_dir.text,rsync_opt)
        else:
            pass 



# 计算指定目录下文件列表
def all_files(checkpath):  
    #checkpath=sys.argv[1]
    result = []  
    for path,subdirs,files in os.walk(checkpath):  
        files.extend(subdirs)  
        files.sort()  
        for name in files:  
            result.append(os.path.join(path,name))  
    print  result
    return result  
  

# 计算指定目录下文件的md5,需调用 def_all_files
def md5sum(src_dir,md5_file,dest_dir):
    AF=open(md5_file,'w')
    AF.close
    for sourcefile in all_files(src_dir):  
        if not sourcefile.endswith('.md5'): 
            print sourcefile 
            p=subprocess.Popen(['md5sum',sourcefile],stdout=subprocess.PIPE,stderr=None)
            stdout = p.communicate()
            AF=open(md5_file,'a')
            AF.write(stdout[0].replace(src_dir,dest_dir+'/srcfile')) 
        else:  
            subprocess.Popen(['cat',sourcefile]) 


# 生成rsync list 文件，调用do_rsync 进行传输
def cp_file(game_select=game_select):
    all_cp_list=[]
    return_xml_mark(game_select)
    if len(sys.argv) == 2:
        file = open(list)
        lines = file.readlines()
        for line in lines:
            cp_tag=rsync_opt.get('bin') + " " + rsync_opt.get('opt') + " " + rsync_opt.get('del') + " " + rsync_opt.get('bw') + rsync_opt.get('key') + " " + src_dir + os.sep +" " + rsync_opt.get('usr')+ '@' + line.strip('\n') + ":" + dest_dir +"/srcfile/"
            all_cp_list.append(cp_tag) 
            cp_tag=rsync_opt.get('bin') + " " + rsync_opt.get('opt') + " " + rsync_opt.get('del') + " " + rsync_opt.get('bw') + rsync_opt.get('key') + " " + conf_dir + os.sep +" " + rsync_opt.get('usr')+ '@' + line.strip('\n') + ":" + dest_dir +"/config/"
            all_cp_list.append(cp_tag) 
            cp_tag=rsync_opt.get('bin') + " " + rsync_opt.get('opt') + " " + rsync_opt.get('del') + " " + rsync_opt.get('bw') + rsync_opt.get('key') + " "+ md5_file +" " + rsync_opt.get('usr')+ '@' + line.strip('\n') + ":" + dest_dir +"/md5/"
            all_cp_list.append(cp_tag) 
        return all_cp_list

    else:
        cp_tag=rsync_opt.get('bin') + " " + rsync_opt.get('opt') + " " + rsync_opt.get('del') + " " + rsync_opt.get('bw') + " " + rsync_opt.get('key') + " " + src_dir + os.sep +" " + rsync_opt.get('usr')+ '@' + sys.argv[2] + ":" + dest_dir +"/srcfile/"
        all_cp_list.append(cp_tag) 
        cp_tag=rsync_opt.get('bin') + " " + rsync_opt.get('opt') + " " + rsync_opt.get('del') + " " + rsync_opt.get('bw') + " " + rsync_opt.get('key') + " " + conf_dir + os.sep +" " + rsync_opt.get('usr')+ '@' + sys.argv[2] + ":" + dest_dir +"/config/"
        all_cp_list.append(cp_tag) 
        cp_tag=rsync_opt.get('bin') + " " + rsync_opt.get('opt') + " " + rsync_opt.get('del') + " " + rsync_opt.get('bw') + " " + rsync_opt.get('key') + " " + md5_file +" " + rsync_opt.get('usr')+ '@' +  sys.argv[2] + ":" + dest_dir +"/md5/"
        all_cp_list.append(cp_tag) 
    return all_cp_list

# 备份原始srcfile
def backup_old_srcfile(game_select=game_select):
    bk_time=time.strftime('%Y%m%d%H%M%S', time.gmtime())
    all_bk_list=[]
    return_xml_mark(game_select)
    if len(sys.argv) == 2:
        file = open(list)
        lines = file.readlines()
        for line in lines:
	    backup_old_srcfile_tag= "ssh " + rsync_opt.get('key')+" "+rsync_opt.get('usr')+ '@' +  line.strip('\n') + " cp -r " + dest_dir + "/srcfile " +  dest_dir+"/srcfile"+bk_time
            all_bk_list.append(backup_old_srcfile_tag)    
        return all_bk_list
    



# 调用rsync_list 
def do_rsync(all):
    os.system(all)

# 远段机器md5_验证
def do_check_remote_host_md5(list,dest_dir,md5_file):
    if len(sys.argv) == 2:
        hosts=open(list)
        md5_all_list = hosts.readlines()
        for i in md5_all_list:
    	    a='ssh ' + i.strip('\n') + " md5sum -c" +" "+ dest_dir + os.sep+"md5/"+ md5_file.split(os.sep,-1)[-1]+ " |grep -vi ok"
            print 'check: ' + i.strip('\n')
            os.system(a)
    else:
        a='ssh ' + sys.argv[2] + " md5sum -c" +" "+ dest_dir + os.sep +"md5/"+ md5_file.split(os.sep,-1)[-1]+ " |grep -vi ok"
        print 'check: ' + sys.argv[2]
        os.system(a)

# 返回xml元素 
if __name__ == '__main__':
    list,md5_file,src_dir,dest_dir,conf_dir,rsync_opt = return_xml_mark(game_select)
    md5sum(src_dir,md5_file,dest_dir)
    print "md5sum calc finish,start trans......"
    if len(sys.argv) == 2: 
        b=backup_old_srcfile(game_select)
        for i in b:
            os.system(i)
            print i
     
    a=cp_file(game_select)
    threads = []
    for i in a:
        t = threading.Thread(target=do_rsync,args=(i,))
        threads.append(t)
    for t in threads:
        t.start()
        while True:
            if(len(threading.enumerate()) < 3):
                print
                break
    print "check reomte md5file......,please wait"
    time.sleep(5)
    do_check_remote_host_md5(list,dest_dir,md5_file)
    
    
