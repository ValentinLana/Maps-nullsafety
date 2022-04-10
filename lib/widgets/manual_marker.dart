import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps/blocs/blocs.dart';
import 'package:maps/helpers/show_loading_message.dart';

class ManualMarker extends StatelessWidget {
  const ManualMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return state.displayManualMarker
            ? const _ManualMarkerBody()
            : const SizedBox();
      },
    );
  }
}

class _ManualMarkerBody extends StatelessWidget {
  const _ManualMarkerBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          const Positioned(
            top: 70,
            left: 20,
            child: _BtnBack(),
          ),
          Center(
            child: Transform.translate(
              //centra el icon de location
              offset: const Offset(0, -20),
              child: BounceInDown(
                from: 100,
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 50,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            left: 40,
            child: FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: MaterialButton(
                minWidth: size.width - 120,
                color: Colors.black,
                height: 50,
                shape: const StadiumBorder(),
                child: const Text(
                  'Confirmar destino',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w300),
                ),
                onPressed: () async {
                  //TODO: loading

                  final start = locationBloc.state.lastKnownLocation;
                  if (start == null) return;

                  final end = mapBloc.mapCenter;
                  if (end == null) return;

                  showLoadingMessage(context);



                  final destination =
                      await searchBloc.getCoorsStartToEnd(start, end);
                        
                  await mapBloc.drawRoutePolyline(destination);

                  searchBloc.add(OnDesactivateManualMarkerEvent());

                  Navigator.pop(context);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _BtnBack extends StatelessWidget {
  const _BtnBack({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      child: CircleAvatar(
        maxRadius: 25,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: () {
            final searchBloc = BlocProvider.of<SearchBloc>(context);
            searchBloc.add(OnDesactivateManualMarkerEvent());
          },
        ),
      ),
    );
  }
}
