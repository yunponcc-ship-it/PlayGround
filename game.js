(() => {
  const canvas = document.getElementById('game');
  const ctx = canvas.getContext('2d');
  const W = canvas.width, H = canvas.height;
  const ui = {
    start: document.getElementById('startOverlay'), end: document.getElementById('endOverlay'),
    startButton: document.getElementById('startButton'), restartButton: document.getElementById('restartButton'),
    shards: document.getElementById('shardCount'), progress: document.getElementById('progressBar'), progressText: document.getElementById('progressText'),
    cooldown: document.getElementById('cooldownBar'), dashStatus: document.getElementById('dashStatus'), toast: document.getElementById('toast'),
    endTitle: document.getElementById('endTitle'), endMessage: document.getElementById('endMessage'), finalScore: document.getElementById('finalScore')
  };
  const platforms = [
    {x:0,y:470,w:420},{x:500,y:425,w:270},{x:840,y:460,w:300},{x:1210,y:405,w:265},
    {x:1540,y:460,w:340},{x:1880,y:430,w:290},{x:2240,y:385,w:265},{x:2580,y:445,w:290},
    {x:2940,y:400,w:285},{x:3310,y:460,w:520}
  ];
  const shards = [
    {x:220,y:426},{x:590,y:381},{x:940,y:416},{x:1300,y:361},
    {x:1690,y:416},{x:1980,y:386},{x:2670,y:401},{x:3450,y:416}
  ];
  const totalShards = shards.length;
  const player = {x:64,y:430,w:27,h:38,vx:0,vy:0,grounded:false,facing:1,invuln:0};
  const camera = {x:0};
  const keys = Object.create(null), touch = {left:false,right:false};
  let started=false, finished=false, collected=0, dashTime=0, dashCooldown=0, checkpointX=64, lastTime=0, time=0, toastTimer=0, jumpBuffer=0;
  let particles=[];
  const drones = [{x:1085,min:880,max:1110,phase:0},{x:2780,min:2610,max:2840,phase:2.1}];
  const clamp=(n,a,b)=>Math.max(a,Math.min(b,n));

  function resetGame(){
    player.x=64;player.y=430;player.vx=0;player.vy=0;player.grounded=false;player.invuln=0;
    camera.x=0;collected=0;dashTime=0;dashCooldown=0;checkpointX=64;finished=false;time=0;particles=[];
    shards.forEach(s=>s.got=false);drones.forEach(d=>d.phase=0);ui.shards.innerHTML=`0 <small>/ ${totalShards}</small>`;ui.progress.style.width='0%';
    ui.progressText.textContent='0% COMPLETADO';ui.cooldown.style.width='100%';ui.dashStatus.textContent='LISTO PARA USAR';ui.end.classList.add('hidden');
  }
  function showToast(text){ui.toast.textContent=text;ui.toast.classList.add('show');toastTimer=1.5;}
  function start(){if(finished)resetGame();started=true;ui.start.classList.add('hidden');}
  ui.startButton.addEventListener('click',start);ui.restartButton.addEventListener('click',()=>{resetGame();start();});
  window.addEventListener('keydown',e=>{
    const k=e.key.toLowerCase(); if([' ','arrowleft','arrowright','arrowup','arrowdown'].includes(k))e.preventDefault();
    if(!keys[k]&&(k===' '||k==='arrowup'||k==='w'))jumpBuffer=.12;
    if(!keys[k]&&(k==='e'||k==='shift'))activateDash();
    keys[k]=true;
    if(k==='enter'&&!started)start();
  },{passive:false});
  window.addEventListener('keyup',e=>{keys[e.key.toLowerCase()]=false;});
  window.addEventListener('blur',()=>{Object.keys(keys).forEach(k=>keys[k]=false);touch.left=touch.right=false;});
  document.querySelectorAll('[data-control]').forEach(button=>{
    const c=button.dataset.control;
    const down=e=>{e.preventDefault();button.setPointerCapture?.(e.pointerId);if(c==='left')touch.left=true;else if(c==='right')touch.right=true;else if(c==='jump')jumpBuffer=.12;else activateDash();};
    const up=e=>{e.preventDefault();if(c==='left')touch.left=false;if(c==='right')touch.right=false;};
    button.addEventListener('pointerdown',down);button.addEventListener('pointerup',up);button.addEventListener('pointercancel',up);button.addEventListener('lostpointercapture',up);
  });
  function activateDash(){if(!started||finished||dashCooldown>0)return;dashTime=.19;dashCooldown=1.15;player.vy*=.15;player.invuln=.24;player.vx=player.facing*11;spawnBurst(player.x+player.w/2,player.y+player.h/2,'#a67aff',12);showToast('GLITCH DASH ACTIVADO');}
  function spawnBurst(x,y,color,n=8){for(let i=0;i<n;i++)particles.push({x,y,vx:(Math.random()-.5)*190,vy:(Math.random()-.5)*170,life:.35+Math.random()*.35,color,size:2+Math.random()*3});}

  function update(dt){
    time+=dt;if(!started||finished)return;
    dt=Math.min(dt,.033); if(jumpBuffer>0)jumpBuffer-=dt;if(dashCooldown>0)dashCooldown=Math.max(0,dashCooldown-dt);if(dashTime>0)dashTime=Math.max(0,dashTime-dt);if(player.invuln>0)player.invuln-=dt;
    const left=keys.arrowleft||keys.a||touch.left,right=keys.arrowright||keys.d||touch.right;
    if(dashTime>0){player.vx=player.facing*11;}else{
      const dir=(right?1:0)-(left?1:0);if(dir){player.vx+=dir*110*dt;player.vx=clamp(player.vx,-220,220);player.facing=dir;}else player.vx*=Math.pow(.001,dt); if(Math.abs(player.vx)<4)player.vx=0;
    }
    if(jumpBuffer>0&&player.grounded){player.vy=-500;player.grounded=false;jumpBuffer=0;spawnBurst(player.x+player.w/2,player.y+player.h,'#4ce5cf',5);}
    player.vy=Math.min(680,player.vy+1250*dt);
    const oldY=player.y;player.x+=player.vx*dt;player.y+=player.vy*dt;
    player.x=clamp(player.x,0,3800-player.w);
    player.grounded=false;
    if(player.vy>=0){for(const p of platforms){if(player.x+player.w>p.x&&player.x<p.x+p.w&&oldY+player.h<=p.y+4&&player.y+player.h>=p.y){player.y=p.y-player.h;player.vy=0;player.grounded=true;break;}}}
    if(player.y>H+80)respawn();
    if(player.x>1895&&checkpointX<1000){checkpointX=1900;showToast('CHECKPOINT GUARDADO');}
    for(const d of drones){d.phase+=dt;d.current=d.x+Math.sin(d.phase*1.6)*78;if(player.invuln<=0&&player.x+player.w>d.current-12&&player.x<d.current+12&&player.y+player.h>d.y-12&&player.y<d.y+18)respawn();}
    for(const s of shards){if(!s.got&&Math.abs((player.x+player.w/2)-s.x)<24&&Math.abs((player.y+player.h/2)-s.y)<27){s.got=true;collected++;spawnBurst(s.x,s.y,'#4ce5cf',13);showToast('FRAGMENTO DE DATOS +1');}}
    const pct=Math.min(100,Math.floor(player.x/3650*100));ui.shards.innerHTML=`${collected} <small>/ ${totalShards}</small>`;ui.progress.style.width=pct+'%';ui.progressText.textContent=`${pct}% COMPLETADO`;
    ui.cooldown.style.width=`${Math.max(0,1-dashCooldown/1.15)*100}%`;ui.dashStatus.textContent=dashCooldown>0?'RECARGANDO…':'LISTO PARA USAR';
    const target=clamp(player.x-W*.36,0,3800-W);camera.x+=(target-camera.x)*Math.min(1,dt*6);
    particles=particles.filter(p=>p.life>0);particles.forEach(p=>{p.life-=dt;p.x+=p.vx*dt;p.y+=p.vy*dt;p.vx*=.96;p.vy*=.96;});
    if(player.x>3690){
      if(collected>=8){finished=true;ui.endTitle.textContent='GG';ui.endMessage.textContent='Escapaste del server roto. El lobby es tuyo.';ui.finalScore.textContent=`${collected} / ${totalShards}`;ui.end.classList.remove('hidden');}
      else{player.x=3680;player.vx=0;if(toastTimer<=0)showToast(`PORTAL BLOQUEADO — ${8-collected} FRAGMENTOS MÁS`);}
    }
    if(toastTimer>0){toastTimer-=dt;if(toastTimer<=0)ui.toast.classList.remove('show');}
  }
  function respawn(){
    if(player.invuln>0)return;player.x=checkpointX;player.y=checkpointX>1000?390:420;player.vx=0;player.vy=0;player.invuln=1.2;dashTime=0;spawnBurst(player.x,player.y,'#ff647c',15);showToast('RESPAWN — EL SERVER TE REINICIÓ');
  }
  function rect(x,y,w,h,color){ctx.fillStyle=color;ctx.fillRect(Math.round(x),Math.round(y),Math.round(w),Math.round(h));}
  function drawBackground(){
    const g=ctx.createLinearGradient(0,0,0,H);g.addColorStop(0,'#101a2d');g.addColorStop(.68,'#111a2b');g.addColorStop(1,'#192239');ctx.fillStyle=g;ctx.fillRect(0,0,W,H);
    // distant neon haze
    const glow=ctx.createRadialGradient(690,290,15,690,290,430);glow.addColorStop(0,'rgba(76,229,207,.11)');glow.addColorStop(1,'rgba(76,229,207,0)');ctx.fillStyle=glow;ctx.fillRect(0,0,W,H);
    // pixel stars and scan grid
    for(let i=0;i<48;i++){let x=((i*193-camera.x*.12)%1050+1050)%1050,y=(i*67%280)+24;rect(x,y,1+(i%3===0),1,'rgba(175,211,239,.32)');}
    ctx.strokeStyle='rgba(113,153,190,.055)';ctx.lineWidth=1;for(let x=0;x<W;x+=40){ctx.beginPath();ctx.moveTo(x,0);ctx.lineTo(x,H);ctx.stroke();}for(let y=0;y<H;y+=40){ctx.beginPath();ctx.moveTo(0,y);ctx.lineTo(W,y);ctx.stroke();}
    // skyline
    for(let i=0;i<19;i++){const wx=i*145-((camera.x*.28)%145),bh=75+(i*53%120),x=wx,y=390-bh;rect(x,y,78,bh,'#111d31');rect(x+5,y+5,68,2,'rgba(102,143,183,.13)');for(let r=0;r<5;r++)for(let c=0;c<3;c++)if((i+r+c)%3!==0)rect(x+12+c*18,y+17+r*16,4,5,(i+c)%4===0?'rgba(75,222,210,.25)':'rgba(126,149,189,.16)');}
    // broken data bars
    for(let j=0;j<4;j++){let x=((j*277-camera.x*.48)%1100+1100)%1100;ctx.fillStyle='rgba(148,102,255,.13)';ctx.fillRect(x,100+j*45,2,18+j*5);ctx.fillStyle='rgba(76,229,207,.15)';ctx.fillRect(x+4,119+j*45,10,1);}
  }
  function drawPlatforms(){
    for(const p of platforms){const x=p.x-camera.x;if(x+p.w<0||x>W)continue;
      rect(x,p.y,p.w,H-p.y+100,'#18283c');rect(x,p.y,p.w,5,'#4ce5cf');rect(x,p.y+5,p.w,2,'rgba(142,255,235,.2)');
      for(let bx=0;bx<p.w;bx+=32){rect(x+bx,p.y+12,1,Math.min(70,H-p.y-12),'rgba(89,127,162,.15)');if(((p.x+bx)/32|0)%2===0)rect(x+bx+7,p.y+21,4,2,'rgba(103,143,182,.18)');}
      // side seams on platform edge
      rect(x,p.y+7,2,Math.min(30,H-p.y),'rgba(76,229,207,.27)');rect(x+p.w-2,p.y+7,2,Math.min(30,H-p.y),'rgba(76,229,207,.27)');
    }
  }
  function drawShard(s){if(s.got)return;const x=s.x-camera.x,y=s.y+Math.sin(time*4+s.x)*4;ctx.save();ctx.translate(x,y);ctx.rotate(time*1.3);ctx.shadowColor='#4ce5cf';ctx.shadowBlur=15;ctx.fillStyle='#56f2da';ctx.beginPath();ctx.moveTo(0,-10);ctx.lineTo(8,0);ctx.lineTo(0,10);ctx.lineTo(-8,0);ctx.closePath();ctx.fill();ctx.shadowBlur=0;ctx.fillStyle='#d2fff5';ctx.fillRect(-1, -5,2,10);ctx.restore();}
  function drawDrone(d){const x=d.current-camera.x,y=d.y;ctx.save();ctx.shadowColor='#ff5a81';ctx.shadowBlur=12;rect(x-9,y-7,18,14,'#de496e');ctx.shadowBlur=0;rect(x-5,y-3,10,6,'#ff9bb0');rect(x-15,y-2,6,3,'#a53256');rect(x+9,y-2,6,3,'#a53256');ctx.fillStyle='rgba(255,73,112,.18)';ctx.beginPath();ctx.moveTo(x-8,y+7);ctx.lineTo(x+8,y+7);ctx.lineTo(x+18,y+30);ctx.lineTo(x-18,y+30);ctx.fill();ctx.restore();}
  function drawPlayer(){
    const x=Math.round(player.x-camera.x),y=Math.round(player.y);if(player.invuln>0&&Math.floor(time*15)%2===0)return;
    ctx.save();if(dashTime>0){ctx.globalAlpha=.35;for(let i=1;i<=3;i++){rect(x-player.facing*i*11,y,player.w,player.h,'#a67aff');}ctx.globalAlpha=1;}
    // block avatar, with crisp toy-like shapes
    rect(x+2,y+12,player.w-4,player.h-12,'#e3a65b');rect(x+1,y+13,player.w-2,14,'#24c7bd');
    rect(x+3,y+1,player.w-6,13,'#edc28a');rect(x+2,y,player.w-4,5,'#553c5d');rect(x+4,y-3,player.w-8,5,'#5b4269');
    rect(x+6,y+7,3,3,'#19273a');rect(x+17,y+7,3,3,'#19273a');rect(x+9,y+12,8,1,'#a76669');
    rect(x+4,y+26,7,10,'#5558a5');rect(x+16,y+26,7,10,'#5558a5');rect(x+3,y+35,9,3,'#252c49');rect(x+15,y+35,10,3,'#252c49');
    // chest pixel badge
    rect(x+12,y+17,4,4,'#a7fff1');ctx.restore();
  }
  function drawWorld(){drawBackground();drawPlatforms();shards.forEach(drawShard);drones.forEach(drawDrone);
    // exit gate
    const gx=3740-camera.x;ctx.save();ctx.shadowColor=collected>=8?'#4ce5cf':'#ff6680';ctx.shadowBlur=20;ctx.strokeStyle=collected>=8?'#4ce5cf':'#ff6680';ctx.lineWidth=4;ctx.strokeRect(gx,392,44,68);ctx.shadowBlur=0;ctx.fillStyle=collected>=8?'rgba(76,229,207,.19)':'rgba(255,102,128,.15)';ctx.fillRect(gx+4,396,36,60);rect(gx+19,417,6,6,collected>=8?'#a1fff1':'#ff8b9b');ctx.fillStyle=collected>=8?'#78f4df':'#ff8c9f';ctx.font='9px DM Mono, monospace';ctx.textAlign='center';ctx.fillText(collected>=8?'EXIT':'LOCKED',gx+22,383);ctx.restore();
    drawPlayer();particles.forEach(p=>{ctx.globalAlpha=clamp(p.life*2,0,1);rect(p.x-camera.x,p.y,p.size,p.size,p.color);});ctx.globalAlpha=1;
    // tiny world coordinate / objective sign
    if(player.x<120){ctx.fillStyle='rgba(7,14,24,.75)';ctx.fillRect(304-camera.x,433,88,24);ctx.fillStyle='#8c9bb0';ctx.font='8px DM Mono,monospace';ctx.textAlign='center';ctx.fillText('JUMP  /  GLITCH',348-camera.x,448);}
    // vignette and subtle scanlines
    const v=ctx.createRadialGradient(W/2,H/2,150,W/2,H/2,610);v.addColorStop(.5,'rgba(0,0,0,0)');v.addColorStop(1,'rgba(2,5,12,.54)');ctx.fillStyle=v;ctx.fillRect(0,0,W,H);
    ctx.fillStyle='rgba(190,221,255,.025)';for(let y=0;y<H;y+=4)ctx.fillRect(0,y,W,1);
  }
  function render(){ctx.clearRect(0,0,W,H);drawWorld();}
  function frame(now){const dt=lastTime?(now-lastTime)/1000:0;lastTime=now;update(dt);render();requestAnimationFrame(frame);}
  resetGame();requestAnimationFrame(frame);
})();
