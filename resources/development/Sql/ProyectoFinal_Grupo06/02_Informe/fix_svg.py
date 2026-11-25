import re,sys
p=sys.argv[1]; s=open(p,encoding='utf-8').read()
def fix(m):
    tag=m.group(0)
    tag=re.sub(r'\s(width|height)="[^"]*"','',tag)
    tag=re.sub(r'style="[^"]*max-width[^"]*"','',tag)
    return tag.replace('<svg ','<svg style="width:100%;height:auto;" ',1)
s,n=re.subn(r'<svg id="mermaid-figure-\d+"[^>]*>',fix,s)
open(p,'w',encoding='utf-8').write(s); print("svgs fixed:",n)
