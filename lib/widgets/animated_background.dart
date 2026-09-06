import 'package:flutter/material.dart';

class BukoAnimatedBackground extends StatefulWidget {
  final Widget child;
  final double opacity;
  const BukoAnimatedBackground({super.key, required this.child, this.opacity = .16});
  @override State<BukoAnimatedBackground> createState() => _BukoAnimatedBackgroundState();
}

class _BukoAnimatedBackgroundState extends State<BukoAnimatedBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  @override void dispose(){_controller.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Stack(fit:StackFit.expand,children:[
    Opacity(opacity: widget.opacity, child: AnimatedBuilder(animation:_controller,builder:(_,__)=>CustomPaint(painter:_MiniCarsPainter(_controller.value)))),
    widget.child,
  ]);
}

class _MiniCarsPainter extends CustomPainter {
  final double t; _MiniCarsPainter(this.t);
  @override void paint(Canvas c, Size s){
    c.drawRect(Offset.zero&s, Paint()..color=const Color(0xFF080B10));
    final glow=Paint()..shader=const RadialGradient(colors:[Color(0x55204A68),Color(0x00080B10)]).createShader(Rect.fromCircle(center:Offset(s.width*.5,s.height*.2),radius:s.width*.8));
    c.drawRect(Offset.zero&s,glow);
    for(int i=0;i<7;i++){
      final y=s.height*(.16+i*.125); final x=((t*(s.width+180)*(.55+i*.07)+i*150)%(s.width+220))-110;
      _car(c,Offset(x,y),.28+(i%3)*.06,i.isEven);
    }
    for(int i=0;i<5;i++){
      final x=((1-t)*(s.width+160)+i*190)%(s.width+160)-80;
      _car(c,Offset(x,s.height*(.84-i*.09)),.22+(i%2)*.05,false);
    }
  }
  void _car(Canvas c,Offset p,double z,bool gold){
    final body=Paint()..color=gold?const Color(0xFF5A4618):const Color(0xFF202A35);
    final glass=Paint()..color=const Color(0xFF111A24);
    final accent=Paint()..color=gold?const Color(0xFFFFB51B):const Color(0xFF566575);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(p.dx-55*z,p.dy-14*z,110*z,28*z),Radius.circular(9*z)),body);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(p.dx-29*z,p.dy-27*z,58*z,20*z),Radius.circular(8*z)),glass);
    c.drawCircle(Offset(p.dx-36*z,p.dy+14*z),8*z,Paint()..color=Colors.black);
    c.drawCircle(Offset(p.dx+36*z,p.dy+14*z),8*z,Paint()..color=Colors.black);
    c.drawLine(Offset(p.dx-43*z,p.dy-1*z),Offset(p.dx+43*z,p.dy-1*z),accent..strokeWidth=2*z);
  }
  @override bool shouldRepaint(covariant _MiniCarsPainter old)=>old.t!=t;
}
