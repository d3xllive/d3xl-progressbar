/* ==========================================================================
   D3XL SCRIPTS - Progress Bar Engine V1 JavaScript
   State-Driven Dynamic Color Feedback:
   - Green Flash + Chime on Success Finish
   - Red Flash + Error Buzzer on Failure / Cancel / Wrong Lockpick
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {

    const pbWrapper = document.getElementById('pbWrapper');
    const pbCardWrapper = document.querySelector('.hud-pb-wrapper');
    const pbLabel = document.getElementById('pbLabel');
    const pbPercent = document.getElementById('pbPercent');
    const pbSegmentsTrack = document.getElementById('pbSegmentsTrack');
    const pbCancelHint = document.getElementById('pbCancelHint');

    const TOTAL_SEGMENTS = 15;
    let currentInterval = null;
    let startTime = 0;
    let totalDuration = 0;
    let isProgressActive = false;

    // Generate 15 Slanted Block Segments inside Track
    function buildSegments() {
        if (!pbSegmentsTrack) return;
        pbSegmentsTrack.innerHTML = '';
        for (let i = 0; i < TOTAL_SEGMENTS; i++) {
            const seg = document.createElement('div');
            seg.className = 'pb-seg';
            pbSegmentsTrack.appendChild(seg);
        }
    }

    buildSegments();

    // Web Audio Synthesizer: Tick, Success Chime & Error Buzzer
    function playAudio(type) {
        if (typeof Config !== 'undefined' && Config.EnableSound === false) return;
        try {
            const Ctx = window.AudioContext || window.webkitAudioContext;
            if (!Ctx) return;
            const ctx = new Ctx();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();

            if (type === 'tick') {
                osc.type = 'sine';
                osc.frequency.setValueAtTime(1200, ctx.currentTime);
                gain.gain.setValueAtTime(0.015, ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.02);
                osc.connect(gain); gain.connect(ctx.destination);
                osc.start(); osc.stop(ctx.currentTime + 0.02);
            } else if (type === 'success') {
                osc.type = 'sine';
                osc.frequency.setValueAtTime(600, ctx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(1200, ctx.currentTime + 0.15);
                gain.gain.setValueAtTime(0.08, ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.15);
                osc.connect(gain); gain.connect(ctx.destination);
                osc.start(); osc.stop(ctx.currentTime + 0.15);
            } else if (type === 'fail') {
                osc.type = 'sawtooth';
                osc.frequency.setValueAtTime(220, ctx.currentTime);
                osc.frequency.setValueAtTime(150, ctx.currentTime + 0.08);
                gain.gain.setValueAtTime(0.1, ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.2);
                osc.connect(gain); gain.connect(ctx.destination);
                osc.start(); osc.stop(ctx.currentTime + 0.2);
            }
        } catch (e) {}
    }

    function startProgress(data) {
        stopProgressImmediately();

        isProgressActive = true;
        totalDuration = parseInt(data.duration || 5000);
        startTime = Date.now();

        if (pbCardWrapper) {
            pbCardWrapper.classList.remove('state-success', 'state-failed');
        }

        if (pbLabel) pbLabel.textContent = (data.label || 'LOADING').toUpperCase();
        if (pbPercent) pbPercent.textContent = '0%';
        if (pbCancelHint) pbCancelHint.style.display = data.canCancel ? 'block' : 'none';

        if (pbWrapper) {
            const pos = data.position || (typeof Config !== 'undefined' ? Config.Position : 'center-bottom');
            pbWrapper.className = `pb-wrapper ${pos}`;
            pbWrapper.style.display = 'flex';
        }

        buildSegments();
        let lastFilled = -1;

        currentInterval = setInterval(() => {
            if (!isProgressActive) return;

            const elapsed = Date.now() - startTime;
            const progressRatio = Math.min(elapsed / totalDuration, 1);
            const percentage = Math.floor(progressRatio * 100);

            if (pbPercent) pbPercent.textContent = `${percentage}%`;

            const filledCount = Math.floor(progressRatio * TOTAL_SEGMENTS);
            const segs = pbSegmentsTrack ? pbSegmentsTrack.children : [];

            for (let i = 0; i < segs.length; i++) {
                if (i < filledCount) {
                    segs[i].classList.add('filled');
                } else {
                    segs[i].classList.remove('filled');
                }
            }

            if (filledCount !== lastFilled && filledCount > 0) {
                lastFilled = filledCount;
                playAudio('tick');
            }

            if (progressRatio >= 1) {
                finishProgressSuccess();
            }
        }, 16); // 60 FPS loop
    }

    // Success State Finish (Green Flash)
    function finishProgressSuccess() {
        if (!isProgressActive) return;
        isProgressActive = false;
        if (currentInterval) clearInterval(currentInterval);

        if (pbCardWrapper) pbCardWrapper.classList.add('state-success');
        if (pbPercent) pbPercent.textContent = '100%';
        playAudio('success');

        // Fill all segments to green
        const segs = pbSegmentsTrack ? pbSegmentsTrack.children : [];
        for (let i = 0; i < segs.length; i++) {
            segs[i].classList.add('filled');
        }

        setTimeout(() => {
            if (pbWrapper) pbWrapper.style.display = 'none';
            if (pbCardWrapper) pbCardWrapper.classList.remove('state-success');
            notifyFiveM('finishProgress');
        }, 350);
    }

    // Failure / Cancel / Wrong Lockpick State (Red Flash)
    function failProgress(reason) {
        if (!isProgressActive) return;
        isProgressActive = false;
        if (currentInterval) clearInterval(currentInterval);

        if (pbCardWrapper) pbCardWrapper.classList.add('state-failed');
        if (pbPercent) pbPercent.textContent = (reason || 'İPTAL').toUpperCase();
        playAudio('fail');

        setTimeout(() => {
            if (pbWrapper) pbWrapper.style.display = 'none';
            if (pbCardWrapper) pbCardWrapper.classList.remove('state-failed');
            notifyFiveM('cancelProgress');
        }, 450);
    }

    function stopProgressImmediately() {
        isProgressActive = false;
        if (currentInterval) clearInterval(currentInterval);
        if (pbWrapper) pbWrapper.style.display = 'none';
        if (pbCardWrapper) pbCardWrapper.classList.remove('state-success', 'state-failed');
    }

    function notifyFiveM(callbackName) {
        fetch(`https://${GetParentResourceName()}/${callbackName}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        }).catch(() => {});
    }

    // Cancel on 'X' Key Press
    window.addEventListener('keydown', (e) => {
        if (isProgressActive && (e.key === 'x' || e.key === 'X' || e.keyCode === 88)) {
            failProgress('İPTAL');
        }
    });

    function GetParentResourceName() {
        return window.GetParentResourceName ? window.GetParentResourceName() : 'd3xl-progressbar';
    }

    // FiveM NUI Listener
    window.addEventListener('message', (e) => {
        const item = e.data || {};
        if (item.action === 'progress' || item.type === 'progress') {
            startProgress(item);
        } else if (item.action === 'cancel' || item.action === 'fail' || item.action === 'stop') {
            failProgress(item.reason || 'İPTAL');
        }
    });

    // Global helper for demo
    window.startProgressDemo = startProgress;
    window.failProgressDemo = failProgress;
});
