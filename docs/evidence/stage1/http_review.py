"""Bounded loopback-only Stage 1 checks; run against an owner-started backend."""
import json, urllib.request, urllib.error, sys
base = sys.argv[1] if len(sys.argv)>1 else 'http://127.0.0.1:5185'
if not base.startswith(('http://127.0.0.1:', 'http://localhost:')):
    raise SystemExit('This review harness only permits local HTTP.')
cases=[]
def add(name, body, expected, path='/trip-plans/preview'):
    cases.append((name, body, expected, path))
valid={'destinationId':'istanbul','days':3,'interests':[]}
for destination,days in [('istanbul',3),('rome',3),('aqaba',2),('istanbul',14)]:
    add(f'{destination}-{days}',dict(valid,destinationId=destination,days=days),200)
for key,value in [('destinationId',None),('destinationId','unknown'),('days',None),('days',0),('days',15),('days',1.5),('days',True),('interests',['unknown']),('interests','history')]:
    add(f'invalid-{key}-{value}',dict(valid,**{key:value}),400)
for name,body in [('missing-days',{'destinationId':'istanbul'}),('malformed','{'),('null-body','null')]: add(name,body,400)
for value in [None,[]]: add(f'interests-{value}',dict(valid,interests=value),200)
add('missing-interests',{'destinationId':'istanbul','days':3},200)
for name,body in [('duplicate-interests',dict(valid,interests=['history','history'])),('budget-extra',dict(valid,budget=123)),('unknown-field',dict(valid,reviewMarker='SYNTHETIC_REVIEW_MARKER')),('string-days',dict(valid,days='3'))]: add(name,body,None)
add('old-client-route',valid,404,'/trips/plan')
results=[]
for name,body,expected,path in cases:
    payload=body if isinstance(body,str) else json.dumps(body)
    req=urllib.request.Request(base+path,data=payload.encode(),headers={'Content-Type':'application/json','Authorization':'Bearer SYNTHETIC_REVIEW_MARKER'},method='POST')
    try:
        with urllib.request.urlopen(req,timeout=5) as r: status=r.status; raw=r.read(65536).decode()
    except urllib.error.HTTPError as e: status=e.code; raw=e.read(65536).decode()
    try: data=json.loads(raw)
    except ValueError: data=raw
    checks={}
    if status==200 and isinstance(body,dict) and isinstance(body.get('days'),int):
        days=data['days']; checks={'days_preserved':len(days)==body['days'],'max_three':all(len(d['places'])<=3 for d in days)}
    results.append({'case':name,'request':body,'status':status,'expected':expected,'matches_expectation':None if expected is None else status==expected,'checks':checks,'body':data})
print(json.dumps(results,indent=2))
