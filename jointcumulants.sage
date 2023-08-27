from sage.all import *

def partitions(points):
    if len(points) == 1:
        yield [ points ]
        return
    first = points[0]
    for smaller in partitions(points[1:]):
        for m, subset in enumerate(smaller):
            yield smaller[:m] + [[ first ] + subset]  + smaller[m+1:]
        yield [ [ first ] ] + smaller

def nonflat(partition,rr):
    n=len(rr); p = []
    for j in partition:    
        for i in range(n):
            j2 = [l for l in j if l > sum(rr[0:i]) and l<=sum(rr[0:(i+1)])]
            p.append(len(j2) <= 1)
    return all(p)

def connected(partition,rr):
    n=len(rr); q = []; c = 0; 
    if n  == 1: return True
    for j in partition:
        jk = [i for i in range(n) if len([l for l in j if l > sum(rr[0:i]) and l<=sum(rr[0:(i+1)])])>=1]
        if(len(jk)>1):            
            if c == 0:
                q = jk; c += 1
            elif(set(q) & set(jk)):
                d=[y for y in (q+jk) if y not in q]
                q = q + d
    return n == len(q)

def connectednonflat(rr):
    n=len(rr); 
    points = list(range(1,sum(rr)+1))
    randd = []
    for m, p in enumerate(partitions(points), 1): randd.append(sorted(p))
    for rou in range(min(rr),sum(rr)-n+2):    
        rs = [d for d in randd if (nonflat(d,rr) and len(d)==rou)]
        rss = [e for e in rs if connected(e,rr)]
        print("Connected non-flat partitions with",rou,"blocks:",len(rss))
    cnfp = [e for e in randd if (connected(e,rr) and nonflat(e,rr))]
    print("Connected non-flat set partitions:",len(cnfp))
    return cnfp

def graphs(G,E,setpartition):
    rr=[len(set(flatten(g))) for g in G];
    n=len(G); rhoG = []
    ee=[len(set(flatten(e))) for e in E];
    for j in range(n):
        m=len(E); 
        for hop in G[j]: rhoG.append([hop[0],hop[1]])
        for l in range(m):
            F=E[l]
            for i in F: rhoG.append([i,sum(rr)+l+1]);
    for i in setpartition:
        if(len(i)>1):
            b = []
            for j in rhoG:
                b.append([i[0] if ele in i else ele for ele in j])
            rhoG = b
    for i in rhoG: i.sort()
    return rhoG

def c(d,G,E,mu,H):
    rr=[len(set(flatten(g))) for g in G];
    if(sum(rr)!=len(set(flatten(G)))):
        print("Wrong G format");
        return 0
    n=len(G);
    ee=[len(set(flatten(e))) for e in E];
    x,y=var("x,y")
    cumulants = 0; ii=0
    z = dict(enumerate([str(x)+str(key)+str(x)+str(l) for key in range(1,sum(rr)+1) for l in range(1,d+1)], start=1))
    cnfp=connectednonflat(rr)
    for setpartition in cnfp: 
        ii=ii+1;print('[%d/%d]\r'%(ii,len(cnfp)),end="")
        rhoG=graphs(G,E,setpartition)
        for j in range(n):
            m=len(E); 
            for l in range(m+1):
                for ld in range(1,d+1): z[d*(sum(rr)+l)+ld] = var(str(y)+str(l)+str('_')+str(ld))
        for key in range(1,sum(rr)+1): 
            for l in range(1,d+1): z[key*d+l] = var(str(x)+str(key)+str(x)+str(l))
        edgesrhoG = [i for n, i in enumerate(rhoG) if i not in rhoG[:n]]
        vertrhoG = set(flatten(edgesrhoG));
        m=len(E); 
        for l in range(m): vertrhoG.remove(sum(rr)+l+1);
        strr = '*λ'*len(vertrhoG)
        for i in vertrhoG:
            for l in range(1,d+1): strr = '*mu({},{},{})'.format(z[i*d+l],λ,β) + strr
            for l in range(1,d+1): strr = strr + ').integrate({},-infinity,+infinity)'.format(z[i*d+l])
        for i in edgesrhoG:
            for l in range(1,d+1): strr = '*H({},{},{})'.format(z[i[0]*d+l],z[i[1]*d+l],β) + strr
        strr = '('*len(vertrhoG)*d+strr[1:]
        cumulants += eval(preparse(strr))
    print("\n");
    cumulants = simplify(cumulants).canonicalize_radical().maxima_methods().rootscontract().simplify()
    return cumulants._sympy_()

λ = var('λ', latex_name=r'\lambda')
β = var('β', latex_name=r'\beta')
ε = var('ε', latex_name=r'\varepsilon')
assume(β>0)

# β=1

def H(x,y,β): return exp(-β*(x-y)**2)
def mu(x,λ,β): return λ*exp(-β*x**2)

# def H(x,y,β): return exp(-β*(x-y)**2)
# def mu(x,λ,β): return 1

G1 = [[1,2],[2,3],[3,2]]
G2 = [[4,5],[5,6],[6,7]]
G = [G1,G2] 

E=[[1,4],[2,5],[3,6]]

c(1,G,E,mu,H)
