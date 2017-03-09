# LGCheckUpdate
iOS app检查更新的工具类
##更新规则
1. 我一般把第一位作为大版本号。如出现重大更新,如果用户不更新,这个app都用不下去了。这个时候就要强制用户更新。 
2. 第二位作为功能版本号。比如增加了一些新的功能。这个时候通过增加这个版本号，来添加功能。 
3. 第三位作为修订版本号。如，上线后出现了一个bug，这个bug需要及时修复，这个时候就增加这个修订版本号。

##效果图
###强制更新
![强制更新](http://img.blog.csdn.net/20170309145704124?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvYXBwbGVMZw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast) <br/>
###可选更新
![可选更新](http://img.blog.csdn.net/20170309145729827?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvYXBwbGVMZw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
       
##解释一下
###强制更新：
在出现第一位版本号变化的时候，强制更新。通过appStore上的版本和当前的版本对比。       
###可选更新：       
在非第一位版本号变化的时候，用户可以选择暂时忽略（下次还会出现这个弹窗），跳过（下次打开不出现），或者更新app。

###blog地址：http://blog.csdn.net/applelg/article/details/60960397
