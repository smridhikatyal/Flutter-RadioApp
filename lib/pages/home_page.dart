import 'package:ai_radioapp/models/radio.dart';
import 'package:ai_radioapp/utils/ai_util.dart';
import 'package:alan_voice/alan_voice.dart';
//import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List<MyRadio> radios;
  Color _selectedColor = Colors.white;
  late List<MyRadio> radios;
  late MyRadio _selectedRadio = MyRadio(
    id: 0,
    order: 0,
    name: "",
    tagline: "",
    color: "",
    desc: "",
    url: "",
    category: "",
    icon: "",
    image: "",
    lang: "",
  );
  //MyRadio? _selectedRadio;

  Color selectedcolor = AIColors.primaryColor1;
  bool _isplaying = false;
  final sugg = [
    "Play",
    "Stop",
    "Play rock music",
    "Play 107 FM",
    "Play next",
    " Play previous",
    "Play pop music",
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    setupAlan();
    radios = [];
    fetchRadios();

    _audioPlayer.playerStateStream.listen((PlayerState playerState) {
      if (playerState.playing) {
        _isplaying = true;
      } else {
        _isplaying = false;
      }
      setState(() {});
    });
  }

  setupAlan() {
    AlanVoice.addButton(
        "7abc1a04a531cbb26b708a4f580e23642e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    AlanVoice.callbacks.add((command) => handleCommand(command.data));
  }

  handleCommand(Map<String, dynamic> response) {
    print("Received command: ${response["command"]}");
    AlanVoice.playText("Received command: ${response["command"]}");
    switch (response["command"]) {
      case "play":
        playMusic(_selectedRadio.url);
        break;

      case "play_channel":
        final id = response["id"];
        // _audioPlayer.pause();
        MyRadio newRadio = radios.firstWhere((element) => element.id == id);
        radios.remove(newRadio);
        radios.insert(0, newRadio);
        playMusic(newRadio.url);
        break;

      case "stop":
        _audioPlayer.stop();
        break;
      case "next":
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index + 1 > radios.length) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index + 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }

        playMusic(newRadio.url);
        break;

      case "prev":
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index - 1 < 0) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index - 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }

        playMusic(newRadio.url);
        break;

      default:
        print("command was ${response["command"]}");
        break;
    }
  }

  fetchRadios() async {
    try {
      final radioJson = await rootBundle.loadString("assests/radio.json");
      setState(() {
        radios = MyRadioList.fromJson(radioJson).radios;
        _selectedRadio = radios[0];
        //   selectedcolor = Color(int.tryParse(_selectedRadio.color));
      });
      print(radios);
      setState(() {});
    } catch (e) {
      print("Error loading radio data: $e");
      // Handle the error accordingly, e.g., show an error message to the user
    }
  }

  playMusic(String url) async {
    // Assuming _audioPlayer supports setFilePath
    final audioSource = AudioSource.uri(Uri.parse(url));
    await _audioPlayer.setAudioSource(audioSource);
    await _audioPlayer.play();
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: selectedcolor ?? AIColors.primaryColor2,
          child: radios != null
              ? [
                  100.heightBox,
                  "ALL Channels".text.xl.white.semiBold.make().px16(),
                  20.heightBox,
                  ListView(
                    children: radios
                        .map((e) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(e.icon),
                              ),
                              title: "${e.name}FM".text.white.make(),
                              subtitle: e.tagline.text.white.make(),
                            ))
                        .toList(),
                  ).expand()
                ].vStack(crossAlignment: CrossAxisAlignment.start)
              : const Offstage(),
        ),
      ),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(
                  colors: [
                    AIColors.primaryColor2,
                    selectedcolor ?? AIColors.primaryColor1,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
              .make(),

          [
            AppBar(
              title: "AI RADIO".text.xl4.bold.white.make().shimmer(
                    primaryColor: Vx.purple300,
                    secondaryColor: Colors.white,
                  ),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).h(100.0).p16(),
            //    20.heightBox,
            "Start with - Hey Alan ".text.italic.semiBold.white.make(),
            10.heightBox,
            VxSwiper.builder(
              itemCount: sugg.length,
              height: 50.0,
              viewportFraction: 0.35,
              autoPlay: true,
              autoPlayAnimationDuration: 3.seconds,
              autoPlayCurve: Curves.linear,
              enableInfiniteScroll: true,
              itemBuilder: (context, index) {
                final s = sugg[index];
                return Chip(
                  label: s.text.make(),
                  backgroundColor: Vx.randomColor,
                );
              },
            )
          ].vStack(alignment: MainAxisAlignment.start),
          30.heightBox,
          Positioned(
            top: 100.0, // Adjust the top value based on your design
            left: 0,
            right: 0,
            bottom: 0,
            child: VxSwiper.builder(
              itemCount: radios.length,
              aspectRatio: context.mdWindowSize == MobileDeviceSize.small
                  ? 1.0
                  : context.mdWindowSize == MobileDeviceSize.medium
                      ? 2.0
                      : 3.0,
              onPageChanged: (index) {
                _selectedRadio = radios[index];
                final colorHex = radios[index].color;
                selectedcolor = Color(int.tryParse(colorHex) ?? 0xFFFFFFFF);
                setState(() {});
              },
              itemBuilder: (context, index) {
                if (index >= 0 && index < radios.length) {
                  final rad = radios[index];

                  return VxBox(
                          child: ZStack(
                    [
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: VxBox(
                          child:
                              rad.category.text.uppercase.white.make().px16(),
                        )
                            .height(40)
                            .black
                            .alignCenter
                            .withRounded(value: 10.0)
                            .make(),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: VStack(
                          [
                            rad.name.text.xl3.white.bold.make(),
                            5.heightBox,
                            rad.tagline.text.sm.white.semiBold.make(),
                          ],
                          crossAlignment: CrossAxisAlignment.center,
                        ),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: [
                            Icon(
                              CupertinoIcons.play_circle,
                              color: Colors.white,
                            ),
                            10.heightBox,
                            "Double tap to play".text.gray300.make(),
                          ].vStack())
                    ],
                  ))
                      .size(context.screenWidth * 0.6,
                          context.screenHeight * 2) // Adjust the size as needed
                      //  .positioned(top: 100.0, left: 16.0) // Adjust the top and left values as needed
                      .clip(Clip.antiAlias)
                      .clip(Clip.antiAlias)
                      .bgImage(DecorationImage(
                        image: NetworkImage(rad.image),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3), BlendMode.darken),
                      ))
                      .border(color: Colors.black, width: 5.0)
                      .withRounded(value: 60.0)
                      .make()
                      .onInkDoubleTap(() {
                        playMusic(rad.url);
                      })
                      .p16()
                      .centered();
                } else {
                  // Handle the case where the index is out of range
                  return Container();
                }
              },
            ),
          ),
          Positioned(
            bottom: context.percentHeight * 12,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: [
                if (_isplaying)
                  "Playing Now - ${_selectedRadio.name} FM "
                      .text
                      .makeCentered(),
                Icon(
                  _isplaying
                      ? CupertinoIcons.stop_circle
                      : CupertinoIcons.play_circle,
                  color: Colors.white,
                  size: 50.0,
                ).onInkTap(() {
                  if (_isplaying) {
                    _audioPlayer.stop();
                  } else {
                    playMusic(_selectedRadio.url);
                  }
                })
              ].vStack(),
            ),
          ),

          //.pOnly(bottom: context.percentHeight * 12)
        ],
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
