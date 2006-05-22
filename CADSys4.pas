{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y-,Z1}
unit CADSys4;

interface

uses Types, SysUtils, Classes, Messages, Windows, Graphics, Controls,
  Contnrs, ComCtrls, Draw, md5, Options0, Geometry, WinBasic;

const
  Drawing_NewFileName = ': Unnamed drawing :';

type
  TeXFormatKind = (tex_tex, tex_pgf, tex_pstricks, tex_eps, tex_png,
    tex_bmp, tex_metapost, tex_emf, tex_none);
  PdfTeXFormatKind = (pdftex_tex, pdftex_pgf, pdftex_pdf, pdftex_png,
    pdftex_metapost, pdftex_epstopdf, pdftex_none);
  ExportFormatKind = (export_SVG, export_EMF, export_EPS, export_PNG,
    export_BMP, export_PDF, export_metapost, export_mps, export_epstopdf,
    export_latexeps, export_latexpdf, export_latexcustom);
  TeXFigureEnvKind = (fig_none, fig_figure, fig_floating, fig_wrap);

const
  TeXFormat_Choice = 'tex;pgf;pstricks;eps;png;bmp;metapost;emf;none';
  PdfTeXFormat_Choice = 'tex;pgf;pdf;png;metapost;epstopdf;none';
  ExportFormat_Choice =
    'svg;emf;eps;png;bmp;pdf;metapost;mps;epstopdf;latexeps;latexpdf;latexcustom';
  ExportDefaultExt = 'svg;emf;eps;png;bmp;pdf;mp;mps;pdf;eps;pdf;*';
  TeXFigure_Choice = 'none;figure;floatingfigure;wrapfigure';

var
  TeXFormat_Default: TeXFormatKind = tex_eps;
  PdfTeXFormat_Default: PdfTeXFormatKind = pdftex_pdf;
  ArrowsSize_Default: TRealType = 0.7;
  StarsSize_Default: TRealType = 1;
  DefaultFontHeight_Default: TRealType = 5;
  //PicWidth_Default: Integer = 75;//=140
  //PicHeight_Default: Integer = 60;//=100
  PicScale_Default: TRealType = 1;
  PicUnitLength_Default: TRealType = 0.05;
  HatchingStep_Default: TRealType = 2;
  HatchingLineWidth_Default: TRealType = 0.5;
  DottedSize_Default: TRealType = 0.5;
  DashSize_Default: TRealType = 1;
  FontName_Default: string = 'Times New Roman';
  TeXMinLine_Default: TRealType = 0.1;
  TeXCenterFigure_Default: Boolean = True;
  TeXFigure_Default: TeXFigureEnvKind = fig_figure;
  LineWidthBase_Default: TRealType = 0.3;
  Border_Default: TRealType = 2;
  PicMagnif_Default: TRealType = 1;
  MetaPostTeXText_Default: Boolean = True;
  IncludePath_Default: string = '';
  DefaultSymbolSize_Default: TRealType = 30;

  // in=72.27pt  in=25.4mm  mm=2.845pt
  // in=72pt  in=25.4mm  mm=2.8346pt

  BezierPrecision: Integer = 150;
  SmoothBezierNodes: Boolean = True;
  RotateText: Boolean = True;
  RotateSymbols: Boolean = True;
  ScaleLineWidth: Boolean = False;

type
{: This type is used by the library for versioning control.
   You doesn't need to change it but you may want to use it
   if you are defining new shapes classes and want to make them
   version indipendent.

   At the moment the version of the library is 'CAD422'.
}
  TCADVersion = array[1..6] of Char;
{: This type define the general type for source block names.
}
  TSourceBlockName = array[0..12] of Char;
{: This type defines the two modality used by <See Class=TCADViewport> to
   copy the viewport drawing area to another canvas with the
   <See Method=TCADViewport@CopyToCanvas> and
   <See Method=TCADViewport@CopyRectToCanvas>.

   These are the modes avaiable:

   <LI=<I=cmNone> ignore the aspect ratio setting.>
   <LI=<I=cmAspect> will use th aspect ratio setting for the copy.>
   <Par>
   <RedBox=<B=Changed>: This type was the TCopyingMode type in the
   old library>.
}
  TCanvasCopyMode = (cmNone, cmAspect);
{: This type defines the modes that can be used by <See Class=TCADViewport> to
   copy the viewport drawing area to another canvas with the
   <See Method=TCADViewport@CopyToCanvas> and
   <See Method=TCADViewport@CopyRectToCanvas>.

   These are the modes avaiable:

   <LI=<I=cvActual> copy the current contents of the viewport.>
   <LI=<I=cvExtension> copy the whole draw.>
   <LI=<I=cvScale> scale the current contents with the given scale factors.>
   <Par>
   <RedBox=<B=Changed>: This type was the TCopyingView type in the
   old library>.
}
  TCanvasCopyView = (cvActual, cvExtension, cvScale);
{: This type defines the modes used to collect a set of objects using the
   <See Method=TCADViewport2D@GroupObjects> and
   <See Method=TCADViewport3D@GroupObjects> methods.

   These are the modes avaiable:

   <LI=<I=gmAllInside> all the objects wholy inside the area are collected.>
   <LI=<I=gmCrossFrame> all the objects wholy or partially inside the area are collected.>
}
  TGroupMode = (gmAllInside, gmCrossFrame);
{: This type defines the string used to name a layer.
}
  TLayerName = string[31];
{: This type defines the possible orientations for a <See Class=TRuler>
   control.

   There are two types of orientations:

   <LI=<I=otOrizontal> the ruler is alligned horizontally.>
   <LI=<I=otVertical> the ruler is alligned vertically.>

   The horizontal ruler is drawed on the left side of the linked
   Viewport and the vertical ruler is drawed on the down side of
   the linked Viewport.
}
  TRulerOrientationType = (otOrizontal, otVertical);
{: This type defines which principal axis is used in a
   <See Class=TCADOrtogonalViewport3D> control.

   The possible combinations are:

   <LI=<I=vtFront> for a view plane with normal along the
     positive (if <See Property=TCADOrtogonalViewport3D@Direction>
     is <I=dtAhead>) or negative Y axis>
   <LI=<I=vtSide> for a view plane with normal along the
     positive (if <See Property=TCADOrtogonalViewport3D@Direction>
     is <I=dtAhead>) or negative X axis>
   <LI=<I=vtFront> for a view plane with normal along the
     positive (if <See Property=TCADOrtogonalViewport3D@Direction>
     is <I=dtAhead>) or negative Z axis>
}
  TOrtoViewType = (vtFront, vtSide, vtTop);
{: This type defines the direction of axis that is used in a
   <See Class=TCADOrtogonalViewport3D> control as the view plane
   normal.

   The possible combinations are:

   <LI=<I=vtFront> for a view plane with normal along the
     positive (if <See Property=TCADOrtogonalViewport3D@Direction>
     is <I=dtAhead>) or negative Y axis>
   <LI=<I=vtSide> for a view plane with normal along the
     positive (if <See Property=TCADOrtogonalViewport3D@Direction>
     is <I=dtAhead>) or negative X axis>
   <LI=<I=vtFront> for a view plane with normal along the
     positive (if <See Property=TCADOrtogonalViewport3D@Direction>
     is <I=dtAhead>) or negative Z axis>
}
  TOrtoDirectionType = (dtAhead, dtBehind);
{: This type identifies the two types of files used by the library:
   <LI=<I=stDrawing> means a drawing file>
   <LI=<I=stLibrary> means a library file>
}
  TStreamType = (stDrawing, stLibrary);

{: This is the base class from which any exception raised by
   library's functions are derived.

   If you want to define your own exception consider to derive
   it from this class.
}
  ECADSysException = class(Exception);
{: This exception is raised when an attempt is made to use an
   unregistered shape class in a method that need a registered
   one.

   <B=Note>: When this exception is raised add the following code
   in the initialization section of one of your units:

   <Code=
    CADSysRegisterClass(<<unused index>>, <<unregistered class type>>);
   >

   Where <I=unused index> must be an unused index above 150.
}
  ECADObjClassNotFound = class(ECADSysException);
{: This exception is raised when you try to delete an source block
   that has references (that has linked instances of <See Class=TBlock2D>
   or <See Class=TBlock3D>).

   In the case of this error remove all the references to the
   source block before retry to delete it.
}
  ECADSourceBlockIsReferenced = class(ECADSysException);
{: This exception is raised when you try to load an invalid drawing
   in a <See Class=TDrawing> instance.

   <B=Note> that this exception is not raised when an old drawing
    file is loaded, in which case a <See Class=TBadVersionEvent> is fired.
}
  ECADFileNotValid = class(ECADSysException);
{: This exception is raised when a specified object is not found
    in the list.
}
  ECADListObjNotFound = class(ECADSysException);
{: This exception is raised when you ask a
   <See Class=TExclusiveGraphicObjIterator> for a list that has already
   active iterators on it.
   Remove the other iterators before retry.

   <B=Note>: When a list has an active iterators that cannot
    be deleted (because you have lost the reference to it), you
    have to call <See Method=TGraphicObjList@RemoveAllIterators> to remove
    all the pending iterators (but not the memory used by them).
    However use this function with care expecially in a multi thread
    application.
}
  ECADListBlocked = class(ECADSysException);

  TDrawing = class;
  TDrawing2D = class;
  TCADViewport = class;
  TCADViewport2D = class;
  TObject2D = class;
  TGraphicObjList = class;
  TGraphicObject = class;
  TGraphicObjectClass = class of TGraphicObject;

  //TSY:
  TOnChangeDrawing = procedure(Drawing: TDrawing) of object;

{: This type defines the event that is fired when an object is added to
   a <See Class=TDrawing> control.

   <I=Sender> is the control in which the object is added;
   <I=Obj> is the object being added.

   It is useful when you want to set some object properties to a default
   value regardless of the procedure that added the object.
}
  TAddObjectEvent = procedure(Sender: TObject; Obj:
    TGraphicObject) of object;
{: This type defines the event that is fired when a drawing created
   with a previous version is being loaded.

   <I=Sender> is the control that tried to load the file;
   <I=Stream> is the stream opened for the file and <I=Version> is the
   version of the library that created the file.
   <I=StreamType> is the type of stream to read.
   <I=Resume> is a flag that force the library to continue to
   loading of the drawing. If this is set to True, the normal
   loading procedure will start at the exit of the event. At
   the call of the procedure it is set to False.

   If you set an handler for this event (see
   <See Property=TDrawing@OnInvalidFileVersion>) you have to do all the
   necessary operation to handle the file.
}
  TBadVersionEvent = procedure(Sender: TObject; const
    StreamType: TStreamType; const Stream: TStream; var Resume:
    Boolean) of object;
{: This type defines the event that is fired when an object is loaded from
   a drawing.

   <I=Sender> is the control that is loading the file;
   <I=ReadPercent> is percentual of the drawing loaded so far.

   This event is useful when you want to inform the user of the progress
   of the loading (see <See Property=TDrawing@OnLoadProgress>).
}
  TOnLoadProgress = procedure(Sender: TObject; ReadPercent: Byte)
    of object;
{: This type defines the event that is fired when an object is saved to
   a drawing.

   <I=Sender> is the control that is loading the file;
   <I=SavePercent> is percentual of the drawing saved so far.

   This event is useful when you want to inform the user of the progress
   of the saving (see <See Property=TDrawing@OnSaveProgress>).
}
  TOnSaveProgress = procedure(Sender: TObject; SavedPercent:
    Byte) of object;
{: This is the type of an event handler for the mouse button event.

   <I=Sender> is the component that has raised the event, <I=Button>
   is the mouse button that has caused the event, <I=Shift> was
   the key configuration when the event was raised.
   <I=WX> and <I=WY> are the X and Y mouse coordinate in the world
   coordinate system ans X, Y are the X and Y mouse coordinate in
   the Windows screen coordinate system.
}
  TMouseEvent2D = procedure(Sender: TObject; Button:
    TMouseButton; Shift: TShiftState; WX, WY: TRealType; X, Y:
    Integer) of object;
{: This is the type of an event handler for the mouse move event.

   <I=Sender> is the component that has raised the event, <I=Shift> was
   the key configuration when the event was raised.
   <I=WX> and <I=WY> are the X and Y mouse coordinate in the world
   coordinate system ans X, Y are the X and Y mouse coordinate in
   the Windows screen coordinate system.
}
  TMouseMoveEvent2D = procedure(Sender: TObject; Shift:
    TShiftState; WX, WY: TRealType; X, Y: Integer) of object;


{: This is the base class for all kinds of graphical objects.

   A graphical object is defined here as an object that:

   <LI=is identifiable by means of an ID number (<See Property=TGraphicObject@ID>)>
   <LI=is on a layer from which inherited a pen and brush for drawing (<See Property=TGraphicObject@Layer>)>
   <LI=may be visibility or not (<See Property=TGraphicObject@Visible>)>
   <LI=may be enabled or not for picking (<See Property=TGraphicObject@Enabled>)>
   <LI=may be saved or not to a stream (<See Property=TGraphicObject@ToBeSaved>)>

   A graphic object define also a common interface for management and storing
   that every object that must be drawed on a viewport must specialize.

   This class cannot be instantiated directly (and even derived from) but
   you must use instead the classes <See Class=TObject2D>, <See Class=TObject3D>
   and the classes derived from them. See the unit <See unit=CS4Shapes>.
}
  TGraphicObject = class(TInterfacedObject)
  private
    fID, fTag: Integer;
    fLayer: Byte;
    fVisible, fEnabled, fToBeSaved: Boolean;
    fOnChange: TNotifyEvent;
    fOwnerCAD: TDrawing;
  protected
{: This method is called when the extensions and shape of the object must
   be updated after some change to the object state was done.

   When you define a new shape you may want to redefine this method in
   order to keep the object in a coerent state. The library call this method
   whenever it has changed the object. Also when you manipulate object you
   must call the <See Method=TGraphicObject@UpdateExtension>, that in order
   call this method, after the object is changed.

   <B=Note>: Some of the objects already defined in the library define this
   method to compute the bounding box of the object and to set some object's
   specific properties, so don't forget to call the inherited method somewhere
   in you implementation.

   <B=Note>: In this method don't fire the <See Property=TGraphicObject@OnChange>
   event.
}
    procedure _UpdateExtension; virtual; abstract;
  public
{: This is the constructor of the graphic object.

   <I=ID> is the identifier of the the object (<See Property=TGraphicObject@ID>).

   The constructor also set:

   <LI=<See Property=TGraphicObject@Layer> to 0>
   <LI=<See Property=TGraphicObject@Visible> to <B=True> >
   <LI=<See Property=TGraphicObject@Enabled> to <B=True> >
   <LI=<See Property=TGraphicObject@ToBeSaved> to <B=True> >
}
    constructor Create(ID: Integer); virtual;
{: This constructor is used to create an instance of the class and initialize
   its state with the one saved to a stream with a previous call to
   <See Method=TGraphicObject@SaveToStream>.

   <I=Stream> is the stream that contains the saved instance's state.
   This stream must be positioned at the starting of the saved image. Note
   that the saved image must be made with the current library version.
   This method is automatically called by the library itself whenever a
   drawing is loaded.

   If the saved object doesn't correspond to the one that the method expect,
   the library may be left in a corrupted state and normally one or more
   <I=EAccessViolation> exceptions will be raised. To resolve this problem
   the library save an header at the start of a drawing to ensure
   the version correctness of the file.

   When you derive a new shape you have to override this method and
   give your own implementation. However remember to call the inherited
   method at the start of your implementation.

   Following the above rules you are ensured that your drawings are
   always readed by the library.

   See <See=Object's Persistance@PERSISTANCE> for details about the PERSISTANCE mecanism of
   the library.
}
{: <New topic=PERSISTANCE@CADSys 4 - Drawing persistance>
   The library is able to save and retrive the current drawing in a
   <See Class=TDrawing> control into a stream or file.

   In order to keep the library customizable and easy to extend, this
   streaming facility is able to save user defined object as well as
   library ones. What you need to do is to simply define how to save
   the state and retrive it from a stream by defing the
   <See Method=TGraphicObject@CreateFromStream> and
   <See Method=TGraphicObject@SaveToStream>. After that you have to
   register your class when your application start by using the
   <See Function=CADSysRegisterClass> procedure.
   With these steps your objects will be saved and retrived automatically
   by the library.

   Simply the library save a <I=class index> before saving the object,
   and then use this index to obtain the <I=class reference> to create
   the object when it must be loaded.

   Using this method the library is also able to automatically load and
   convert drawing created with old version of the library without
   need to create an explicit version converter.

   Most of the shapes in the library use this method extensively and
   you have only to save you own datas if you need by using simply
   <I=Read> and <I=Write> method of <I=TStream>.
   Also you don't need to know if your drawing is to be saved in a
   file, in a memory stream or also into a database record.
}
    constructor CreateFromStream(const Stream: TStream; const
      Version: TCADVersion); virtual;
  //TSY:
    constructor CreateDupe(Obj: TGraphicObject); virtual;
{: This method save an image of the current state of the object to a stream.

   <I=Stream> is the stream on which save the image.

   When you derive a new shape you have to override this method and
   augument it with what you need to save the object state. This method
   will be called automatically by the library when the current drawing
   is being saved but you may want to call it directly to save a contained
   shape of another object. If the <See Property=TGraphicObject@ToBeSaved>
   property is set to <B=False> the object will not be saved by the library.

   See <See=Object's Persistance@PERSISTANCE> for details about the PERSISTANCE mecanism of
   the library.
}
    procedure SaveToStream(const Stream: TStream); virtual;
{: This method is used to make deep copy of the object by obtaining state
   informations from another.

   <I=Obj> is the object from which copy the needed informations. Note that
   this object doen't need to be of the same class of the object into which
   copy these informations. You have to check this class before accessing
   the informations. You have also to call the inherited method if you
   plan to override this method so the responsability chain is maintained.

   The parents classes of the objects from which this method is called
   are traversed to copy as much as possible from the given <I=Obj>.

   <B=Note>: If you use memory allocation remember to copy the memory
   and not simply copy the reference. This is also true with contained
   objects.
}
    procedure Assign(const Obj: TGraphicObject); virtual;
{: This method is called when the extensions and shape of the object must
   be updated after some change to the object state was done.

   When you define a new shape you may want to redefine this method in
   order to keep the object in a coerent state. The library call this method
   whenever it has changed the object. Also when you manipulate object you
   must call this method after the object is changed.
   You may want to override the <See Method=TGraphicObject@_UpdateExtension>
   to give special updates for your shape.

   This method fires a <See Property=TGraphicObject@OnChange> event.
}
    procedure UpdateExtension(Sender: TObject);
{: This property defines the ID of the object.

   Any graphic object is identified through th library by means of a
   <I=Integer> number that must univocally identify it. The library by
   itself doesn't check for uniqueness of these IDs so you have to ensure
   it by yourself.
}
    property ID: Integer read fID write fID;
{: This property contains the layer on which the object lies.

   Any graphic object is associated with a layer from which they get
   their drawing caracteristic such as color, line style, fill color
   and so on.

   An object also get the behavior of this layer such us visibility
   and enabling to picking that have priority on the ones of the
   object.

   If you want to have object specific color you have to change the
   color in the <I=Draw> method of the shape. You don't need to
   revert the object to the one of the layer after you have modified the
   current pen color, because the library will reset this color before
   the <I=Draw> method is called.

   By Dafault this property is set to <B=0>.
}
    property Layer: Byte read fLayer write fLayer;
{: This property specify the visibility of the object.

   If it is <B=True> then the object is drawed on the viewport otherwise
   it will not be drawed (the viewport on which it will be drawed depend
   on the <See Class=TDrawing> control into which the object is stored).

   The <See Property=TLayer@Visible> setting of the layer on which the
   object lies has the priority on this property.

   By Dafault this property is set to <B=True>.
}
    property Visible: Boolean read fVisible write fVisible;
{: This property specify the behaviour of the object when it is picked.

   If it is <B=False> then the object will not be considered by the picking
   methods, otherwise it may be picked.

   The <See Property=TLayer@Active> setting of the layer on which the
   object lies has the priority on this property.

   By Dafault this property is set to <B=True>.
}
    property Enabled: Boolean read fEnabled write fEnabled;
{: This property specify if the object is to be saved in a drawing.

   If it is <B=False> then the object will not be saved into a drawing stream,
   otherwise it will be.

   The <See Property=TLayer@Streamable> setting of the layer on which the
   object lies has the priority on this property.

   By Dafault this property is set to <B=True>.
}
    property ToBeSaved: Boolean read fToBeSaved write
      fToBeSaved;
{: This read-only property contains the CAD in which the object was added.
   Although you can add the same object to more than one CAD (and you can
   do that safely by removing all the references from the CADs without deleting
   the object) it isn't a good practice and it is discouraged because this
   property will not still have any meaning.
}
    property OwnerCAD: TDrawing read fOwnerCAD;
{: This property may be used to store some user's defined data
   like object references.
   It is not used by the library.

   One of the most useful use of this property is when you need to
   link an object to a shape. Consider for example that you have
   a class TSurface in which you store informations like the
   reflectivity coefficent, the color for rendering, the adiacent
   surfaces and the points of the surface. The instances of this class
   are managed by the program that save them and so on. You need of
   course to draw them and manage them interactively (you may want to
   do that instead to change them through the list of points).

   The library can help you in this, bacause you can use the <See Class=TFace3D>
   shape that cames whith the library and that has a list of points and
   that is drawed and managed interactively by the various interaction tasks
   of the library. However if you naive add an instance of TFace3D and
   an instance of TSurface and link them through the ID property of TFace3D,
   you will have duplication of data and a difficult task to syncronize the
   two instances. A better approach is to store the TSurface reference into
   the Tag property and a TFace3D reference in the TSurface instance.
   After that you have to move any geometric datas from TSurface to the TFace3D.
   In our example simply use the TFace3D to store the points and normal, instead
   use the TSurface to store color and coefficients.
   In this way whenever the user modify the shape, the TSurface is automatically
   updated. If there is some data in TSurface that depends on the datas of TFace3D
   (for instance a baricentric point) you have two way to update this data:

   <LI=Derive from TFace3D a new shape with the added data>
   <LI=Put the data in TSurface and the add an event handler that will be
   used for the <See Property=TGraphicObject@OnChange> event>

   With the second solution whenever the points are moved the new
   baricentric point will be calculated.

   This is only a simple and not optimized way to handle these problems.
}
    property Tag: Integer read fTag write fTag;
{: This is property can store an event-handler for the event <I=OnChange>
   that occour whenever an object is modified (actually the event is
   fired only when the user or the library call <See Method=TGraphicObject@UpdateExtension>
   method).

   You may want to use this event as described in the description of the
   <See Property=TGraphicObject@Tag> property.
}
    property OnChange: TNotifyEvent read fOnChange write
      fOnChange;
  end;


  { Lists of graphical objects. }
{: This class defines an iterator for a list of graphical objects
   (<See class=TGraphicObjList>).

   The library can use a <I=thread> to paint the drawings and so
   a way is needed to ensure that a list is not changed when it is
   in use by another thread.

   To do so the concept of <I=iterator> is used. An iterator is
   an object that is used to traverse a list of objects. When you
   ask and obtain an iterator on a list, you can access the elements
   in the list through the iterator. You cannot modify a list if you
   doesn't have an <I=exclusive iterator> that let you to modify the
   list as well as iterate it (<See Class=TExclusiveGraphicObjIterator>).

   As soon as you obtain an iterator the list cannot be modified and
   so you are ensured that it will remain the same during the iteration.
   Of course if you doen't release an iterator you cannot modify the list
   until the end of the program, so attention is needed when using an
   iterator.

   For backward compatibility some operations on the list are avaiable
   with the list itself (and these are however implemented with temporary
   iterators so using them is the better approach).

   See also <See Class=TExclusiveGraphicObjIterator> and
   <See Class=TGraphicObjList>.

   <B=Note>: To release an iterator simply free it. If you lost some
   reference to iterators (and so the list is blocked) you can unblock
   the list with the method <See Method=TGraphicObjList@RemoveAllIterators>.

   <B=Note>: An iterator cannot be created directly but only with the
   use of the methods <See Method=TGraphicObjList@GetIterator>,
   <See Method=TGraphicObjList@GetExclusiveIterator> and
   <See Method=TGraphicObjList@GetPrivilegedIterator>.
}
  TGraphicObjIterator = class(TObject)
  private
    fCurrent: Pointer;
    fSourceList: TGraphicObjList;

    function GetCurrentObject: TGraphicObject;
    function SearchBlock(ID: Integer): Pointer;
    function GetCount: Integer;
    constructor Create(const Lst: TGraphicObjList); virtual;
  public
{: This is the descructor of the iterator.

   When an iterator is freed (with the use of <I=Free>) the iterator's
   count in the list from which the iterator was obtained will be decremented
   and the list will be unblocked if it was.

   <B=Remeber to free all the iterators you have when you finish with
   them>.
}
    destructor Destroy; override;
{: Return the object with the specified <I=ID> if found. If that object
   doen't exist in the list <B=nil> will be returned.

   If an object is found then the position in the list will be moved
   to it, if no it will not be moved.
   No exception is raised if no object is found.
}
    function Search(const ID: Integer): TGraphicObject;
{: Move the current position (<See Property=TGraphicObjIterator@Current>
   to the next object in the list, and return it.

   If the current position is at the end of the list the current position
   will be set to <B=nil> and <B=nil> will be returned.
}
    function Next: TGraphicObject;
{: Move the current position (<See Property=TGraphicObjIterator@Current>
   to the previous object in the list, and return it.

   If the current position is at the beginnig of the list the current position
   will be set to <B=nil> and <B=nil> will be returned.
}
    function Prev: TGraphicObject;
{: Move the current position (<See Property=TGraphicObjIterator@Current>
   to the first object in the list, and return it.

   If the list is empty current position
   will be set to <B=nil> and <B=nil> will be returned.
}
    function First: TGraphicObject;
{: Move the current position (<See Property=TGraphicObjIterator@Current>
   to the last object in the list, and return it.

   If the list is empty current position
   will be set to <B=nil> and <B=nil> will be returned.
}
    function Last: TGraphicObject;
{: This property contains the number of items in the list.

   You may want to use it in combination with
   <See Property=TGraphicObjIterator@Items> to iterate the list
   in an array-like mode.
}
    property Count: Integer read GetCount;
{: This property contains the current object onto which the iterator
   is positioned. If the position is invalid it will be <B=nil>.
}
    property Current: TGraphicObject read GetCurrentObject;
{: This property contains the list linked to the iterator.
}
    property SourceList: TGraphicObjList read fSourceList;
{: This property contains the items in the list.

   You may want to use it in combination with
   <See Property=TGraphicObjIterator@Count> to iterate the list
   in an array-like mode.

   <I=ID> is zero based so the bounds of the array are from <I=0> to
   <See Property=TGraphicObjIterator@Count>.
}
    property Items[const ID: Integer]: TGraphicObject read
    Search; default;
  end;

{: This class defines an exclusive iterator for a list of graphical objects
   (<See class=TGraphicObjList>).

   The library can use a <I=thread> to paint the drawings and so
   a way is needed to ensure that a list is not changed when it is
   in use by another thread.

   To do so the concept of <I=iterator> is used. An iterator is
   an object that is used to traverse a list of objects. When you
   ask and obtain an iterator on a list, you can access the elements
   in the list through the iterator. You cannot modify a list if you
   doesn't have an <I=exclusive iterator> that let you to modify the
   list as well as iterate it (<See Class=TExclusiveGraphicObjIterator>).

   As soon as you obtain an iterator the list cannot be modified and
   so you are ensured that it will remain the same during the iteration.
   Of course if you doen't release an iterator you cannot modify the list
   until the end of the program, so attention is needed when using an
   iterator.

   For backward compatibility some operations on the list are avaiable
   with the list itself (and these are however implemented with temporary
   iterators so using them is the better approach).

   See also <See Class=TExclusiveGraphicObjIterator> and
   <See Class=TGraphicObjList>.

   <B=Note>: To release an iterator simply free it. If you lost some
   reference to iterators (and so the list is blocked) you can unblock
   the list with the method <See Method=TGraphicObjList@RemoveAllIterators>.

   <B=Note>: An iterator cannot be created directly but only with the
   use of the methods <See Method=TGraphicObjList@GetIterator>,
   <See Method=TGraphicObjList@GetExclusiveIterator> and
   <See Method=TGraphicObjList@GetPrivilegedIterator>.
}
  TExclusiveGraphicObjIterator = class(TGraphicObjIterator)
  private
    constructor Create(const Lst: TGraphicObjList); override;
  public
    destructor Destroy; override;
{: This method delete the current object from the source list.
   After the object is deleted the current position in the list
   will be set to the next object in it (if it is at the end
   of the list it will be set to the previous object).

   This method is affected by the state of the
   <See Property=TGraphicObjList@FreeOnClear> property.
}
    procedure DeleteCurrent;
{: This method remove the current object from the source list but
   doesn't free it.
   After the object is removed the current position in the list
   will be set to the next object in it (if it is at the end
   of the list it will be set to the previous object).

   This method is <B=NOT> affected by the state of the
   <See Property=TGraphicObjList@FreeOnClear> property.
}
    procedure RemoveCurrent;
    //TSY: deletes object from the list and puts another object to that place
    procedure ReplaceDeleteCurrent(const Obj: TGraphicObject);
  end;

{: This class defines a double linked list of graphic objects.

   The objects are referenced in the list through their
   identifier number (<See Property=TGraphicObject@ID>). The list doens't
   check for duplicated <I=ID> so you have to ensure uniqueness by yourself.

   To traverse the list you have to use instances of
   <See Class=TGraphicObjIterator> and <See Class=TExclusiveGraphicObjIterator>
   that can be obtained with the methods <See Method=TGraphicObjList@GetIterator>,
   <See Method=TGraphicObjList@GetExclusiveIterator> and <See Method=TGraphicObjList@GetPrivilegedIterator>.

   All of the methods that modify the list can be used only if no iterators
   are attached to the list. If this is not the case an
   <See Class=ECADListBlocked> exception will be raised.

   The list can own the object it contains depending on the setting of
   the property <See Property=TGraphicObjList@FreeOnClear>.
}
  TGraphicObjList = class(TObject)
  private
    fHead, fTail: Pointer;
    fHasExclusive, fFreeOnClear: Boolean;
    fIterators: Integer; { Usato come semaforo. }
    fCount: Integer;
    fListGuard: TCADSysCriticalSection;

    procedure DeleteBlock(ObjToDel: Pointer);
    procedure RemoveBlock(ObjToDel: Pointer);
    function GetHasIter: Boolean;
  public
{: This is the constructor of the list. It creates a new empty list.

  It sets <See Property=TGraphicObjList@FreeOnClear> to <B=True>.
}
    constructor Create;
{: This is the destructor of the list.

  If the property <See Property=TGraphicObjList@FreeOnClear> is <B=True>
  the the objects in the list will also be freed.
}
    destructor Destroy; override;
{: This method adds an object to the list.

   The added object <I=Obj> will be placed at the end of the list, after
   any other object already present in the list. The list doesn't check
   for uniqueness of the object's <See Property=TGraphicObject@ID>.

   If the list has some iterators active on it a
   <See Class=ECADListBlocked> exception will be raised.
}
    procedure Add(const Obj: TGraphicObject);
{: This method adds all the object in another list <I=Lst> to the list.

   The added objects will be placed at the end of the list, after
   any other object already present in the list. The list doesn't check
   for uniqueness of the object's <See Property=TGraphicObject@ID>.

   If the list has some iterators active it a
   <See Class=ECADListBlocked> exception will be raised.
}
    procedure AddFromList(const Lst: TGraphicObjList);
{: This method inserts an object into the list.

   The added object <I=Obj> will be inserted after the object in the
   list with ID equal to <I=IDInsertPoint>. If no such object is present
   a <See Class=ECADListObjNotFound> exception will be raised.
   The list doesn't check for uniqueness of the inserted object.

   If the list has some iterators active on it a
   <See Class=ECADListBlocked> exception will be raised.
}
    procedure Insert(const IDInsertPoint: Integer; const Obj:
      TGraphicObject);
{: This method moves an object into the list.

   The object with ID equal to <I=IDToMove> will be moved before the
   object in the list with ID equal to <I=IDInsertionPoint> .
   If no such object is present a <See Class=ECADListObjNotFound>
   exception will be raised.

   If the list has some iterators active it a
   <See Class=ECADListBlocked> exception will be raised.

   <B=Note>: This method is useful if you want to change the
   drawing order in the list of object of a <See Class=TDrawing>
   control.
}
    procedure Move(const IDToMove, IDInsertPoint: Integer);
{: This method deletes an object from the list.

   The object with ID equal to <I=ID> will be deleted.
   If no such object is present a <See Class=ECADListObjNotFound>
   exception will be raised.

   If the list has the property <See Property=TGraphicObjList@FreeOnClear>
   set to <B=True> then the object will be deleted by calling its <I=Free>
   method.

   If the list has some iterators active on it a
   <See Class=ECADListBlocked> exception will be raised.

   <B=Note>: If you want to delete more that one object from the
   list use an exclusive iterator for better performances.
}
    function Delete(const ID: Integer): Boolean;
{: This method removes an object from the list.

   The object with ID equal to <I=ID> will be removed.
   If no such object is present a <See Class=ECADListObjNotFound>
   exception will be raised.

   The object will not also be deleted if the property <See Property=TGraphicObjList@FreeOnClear>
   is set to <B=True>.

   If the list has some iterators active on it a
   <See Class=ECADListBlocked> exception will be raised.

   <B=Note>: If you want to remove more that one object from the
   list use an exclusive iterator for better performances.
}
    function Remove(const ID: Integer): Boolean;
{: This method returns the object with the gived Id.

   The object with ID equal to <I=ID> will be returned if found, or <B=nil>
   will be returned if no object is found.

   If the list has some exclusive iterators active on it a
   <See Class=ECADListBlocked> exception will be raised.

   <B=Note>: If you have an iterator on the list don't use this method.
   Use it only if you want to find a single object.
}
    function Find(const ID: Integer): TGraphicObject;
{: This method remove all the object from the list.

   The objects will be deleted if the property <See Property=TGraphicObjList@FreeOnClear>
   is set to <B=True>.

   If the list has some iterators active on it a
   <See Class=ECADListBlocked> exception will be raised.
}
    procedure Clear;
{: This method set a new iterator on the list.

   The new iterator will be returned and you can start to use it.
   After you have used it remember to <B=Free> it. It is better to
   protect the use of the iterator in a <B=try-finally> block.

   If the list has an exclusive iterator active on it a
   <See Class=ECADListBlocked> exception will be raised.
}
    function GetIterator: TGraphicObjIterator;
{: This method set a new exclusive iterator on the list.

   The new iterator will be returned and you can start to use it.
   After you have used it remember to <B=Free> it. It is better to
   protect the use of the iterator in a <B=try-finally> block.

   An exclusive iterator prevent any other thread to modify the list,
   so grant you an exclusive use of the list. With this kind of
   iterator you can remove objects from the list.

   If the list has any iterators active on it a
   <See Class=ECADListBlocked> exception will be raised.
}
    function GetExclusiveIterator: TExclusiveGraphicObjIterator;
{: This method set a new exclusive iterator on the list ignoring
   any other pending iterator already present.

   The new iterator will be returned and you can start to use it.
   After you have used it remember to <B=Free> it. It is better to
   protect the use of the iterator in a <B=try-finally> block.

   A priviliged iterator is somewhat dangerous and must be used only
   in case of error when an iterator was active on the list and cannot
   be freed (for instance it is useful when the application must be
   aborted in presence of errors but you want to save any other
   present in the CAD).
}
    function GetPrivilegedIterator:
      TExclusiveGraphicObjIterator;
{: This method removes any pending iterator active on the list.

   This method is somewhat dangerous and must be used only
   in case of error when an iterator was active on the list and cannot
   be freed (for instance it is useful when the application must be
   aborted in presence of errors but you want to save any other
   present in the CAD).
}
    procedure RemoveAllIterators;
    procedure TransForm(const T: TTransf2D);
//TSY: reproduced from viewport method with the same name
    function PickObject(const PT: TPoint2D;
      Drawing: TDrawing2D; const Aperture: TRealType;
      const VisualRect: TRect2D; const DrawMode: Integer;
      const FirstFound: Boolean; var NPoint: Integer): TObject2D;
{: This property returns the number of objects present in the list.

   It is useful when you want to iterate through the object in the
   list with an iterators.
}
    property Count: Integer read fCount;
{: This property returns <B=True> if the list has some iterator active on
   it.

   Check this property before asking for an iterator.
}
    property HasIterators: Boolean read GetHasIter;
{: This property returns <B=True> if the list has an exclusive iterator
   active on it.

   Check this property before asking for an exclusive iterator.
}
    property HasExclusiveIterators: Boolean read fHasExclusive;
{: This property tells the list if the objects in the list must
   be freed when removed from it.

   If it is set to <B=True> the objects in the list are deleted
   (by calling their <I=Free> method) when they are removed from
   the list by using the <See Method=TGraphicObjList@Delete>,
   <See Method=TGraphicObjList@Clear> methods or when the list
   is deleted.
}
    property FreeOnClear: Boolean read fFreeOnClear write
      fFreeOnClear;
  end;

{: It is a indexed list of objects, that can be accessed in an array-like
   mode.
}
  TIndexedObjectList = class(TObject)
  private
    fListMemory: Pointer;
    fNumOfObject: Integer;
    fFreeOnClear: Boolean;

    procedure SetListSize(N: Integer);
    procedure SetObject(IDX: Integer; Obj: TObject);
    function GetObject(IDX: Integer): TObject;
  public
    {: Create a new empty list that can store no more that <I=Size> objects.
    }
    constructor Create(const Size: Integer);
    {: This is the destructor of the list.

       If the property <See Property=TIndexedObjectList@FreeOnClear> is <B=True>
       the the objects in the list will also be freed.
    }
    destructor Destroy; override;
    {: This method remove all the object from the list.

      The objects will be deleted if the property <See Property=TIndexedObjectList@FreeOnClear>
      is set to <B=True>.
    }
    procedure Clear;
    {: This property contains the objects in the list.

       <I=Idx> goes from 0 to <See Property=TIndexedObjectList@NumberOfObjects>.
    }
    property Objects[IDX: Integer]: TObject read GetObject write
    SetObject; default;
    {: This property contains the number of objects in the list.
    }
    property NumberOfObjects: Integer read fNumOfObject write
      SetListSize;
    {: This property tells the list if the objects in the list must
       be freed when removed from it.

       If it is set to <B=True> the objects in the list are deleted
       (by calling their <I=Free> method) when they are removed from
       the list by using the <See Method=TGraphicObjList@Delete>,
       <See Method=TGraphicObjList@Clear> methods or when the list
       is deleted.
    }
    property FreeOnClear: Boolean read fFreeOnClear write
      fFreeOnClear;
  end;

{: This type defines the layer used by the library.

   Any graphic object is associated with a layer from which they get
   their drawing caracteristic such as color, line style, fill color
   and so on.

   An object also get the behavior of this layer such us visibility
   and enabling to picking that have priority on the ones of the
   object.
}
  TLayer = class(TObject)
  private
    fPen: TPen;
    fBrush: TBrush;
    fDecorativePen: TDecorativePen;
    fName: TLayerName;
    fActive: Boolean;
    fVisible: Boolean;
    fOpaque: Boolean;
    fModified: Boolean;
    fStreamable: Boolean;
    fIdx: Byte;
    fTag: Integer;

    procedure SetName(NM: TLayerName);
    procedure SetPen(Pn: TPen);
    procedure SetBrush(BR: TBrush);
    procedure Changed(Sender: TObject);
  public
{: This is the constructor of the layer.

   <I=Idx> is the index number of the layer. The layers are indexed from
   0 to 255.

   The constructor sets:

   <LI=<See Property=TLayer@Name> to <I=Layer<<Idx>> > >
   <LI=<See Property=TLayer@Pen> to the pen <B=clBlack> and <B=psSolid> >.
   <LI=<See Property=TLayer@Brush> to the brush <B=clWhite> and <B=psSolid> >
   <LI=<See Property=TLayer@Active> to <B=True> >
   <LI=<See Property=TLayer@Visible> to <B=True> >
   <LI=<See Property=TLayer@Opaque> to <B=False> >
   <LI=<See Property=TLayer@Streamable> to <B=True> >
   <LI=<See Property=TLayer@Modified> to <B=False> >
}
    constructor Create(IDX: Byte);
{: This is the destructor of the layer, it destroys the pen and brush
   objects.
}
    destructor Destroy; override;
{: This method saves the layer settings to a stream.

   <I=Stream> is the stream onto which save the settings.
}
    procedure SaveToStream(const Stream: TStream); virtual;
{: This method retrieves the layer settings from a stream.

   <I=Cont> is the index of the layer, <I=Stream> is the stream that
   contains the settings and <I=Version> is the version of the library that
   has saved the layer.
}
    procedure LoadFromStream(const Stream: TStream; const
      Version: TCADVersion); virtual;
{: This method set the canvas pen and brush values to the one defined by
   the layer.

   <I=Cnv> is the Canvas to be modified <See Class=TDecorativeCanvas@TDecorativeCanvas>.
   The method returns <B=True> if the layer
   is visible and the pen and brush of the canvas are modified.
}
    function SetCanvas(const Cnv: TDecorativeCanvas): Boolean;
{: This property contains the name of the layer.
}
    property Name: TLayerName read fName write SetName;
{: This property contains the decorative pen object used to draw the objects
   on the layer.

   See also <See Class=TDecorativePen> for details.
}
    property DecorativePen: TDecorativePen read fDecorativePen;
{: This property contains the pen object used to draw the objects on the
   layer.
}
    property Pen: TPen read fPen write SetPen;
{: This property contains the brush object used to draw the objects on the
   layer.

   If you want to change the default pen of the layers use the
   <See Method=TDrawing@SetDefaultPen>.
}
    property Brush: TBrush read fBrush write SetBrush;
{: This property tells if the objects on the layer are considered for the
   picking operations.

   If you want to change the default brush of the layers use the
   <See Method=TDrawing@SetDefaultBrush>.
}
    property Active: Boolean read fActive write fActive;
{: This property tells if the objects on the layer are drawed or not.
}
    property Visible: Boolean read fVisible write fVisible;
{: This property tells if the objects on the layer are opaque (<B=True>) or
   transparent.

   If an object is transparent then the brush will not cover the background.
}
    property OPAQUE: Boolean read fOpaque write fOpaque;
{: This property is <B=True> if the layer was modified and so it must be
   saved, otherwise it will not be saved to a drawing.

   If a layer is not saved it will get the default settings.
}
    property Modified: Boolean read fModified;
{: This property is <B=True> if the objects on the layer must be saved into
   a drawing.

   If this property is <B=False> the objects on the layer are not saved. This
   is useful if you want to save some object into another stream (or a container
   object save it as part of its state).
}
    property Streamable: Boolean read fStreamable write
      fStreamable;
{: This property is index of the layer that ranges from 0 to 255.
}
    property LayerIndex: Byte read fIdx;
{: This property is not used by the library and so can be used to store
   user defined values like object references.
}
    property Tag: Integer read fTag write fTag;
  end;

{: This class defines a set of 256 layers (from 0 to 255).
   Every <See Class=TDrawing> control has an instance of this class.

   This class manage all the layers and stream them on a file.
}
  TLayers = class(TObject)
  private
    fLayers: TList;

    function GetLayer(Index: Byte): TLayer;
    function GetLayerByName(const NM: TLayerName): TLayer;
  public
{: This is the constructor of the class. It creates a new istance of the set of layers and initialize all
   the layers to the default settings.
}
    constructor Create;
{: This is the destructor of the class. It destroy the set and all of the
   contained layers.
}
    destructor Destroy; override;
{: This method saves only the modified layers into a drawing stream.
}
    procedure SaveToStream(const Stream: TStream);
{: This method retrieve the layers from a drawing stream.
}
    procedure LoadFromStream(const Stream: TStream; const
      Version: TCADVersion);
{: This method set the canvas pen and brush values to the one defined by
   a layer.

   <I=Cnv> is the Canvas to be modified <See Class=TDecorativeCanvas@TDecorativeCanvas>,
   <I=Index> is the index of the layer
   to be used. The method returns <B=True> if the layer is visible and the
   pen and brush of the canvas are modiefied.
}
    function SetCanvas(const Cnv: TDecorativeCanvas; const
      Index: Byte): Boolean;
{: This property contains the set of 256 layers.

   Use this property to change the setting of a layer for a <See Class=TDrawing>.
}
    property Layers[Index: Byte]: TLayer read GetLayer; default;
{: This property contains the set of 256 layers that can be accessed through
   their names.

   If <I=Nm> doesn't correspond to any of the layers it returns <B=nil>.
   Use this property to change the setting of a layer for a <See Class=TDrawing>.
}
    property LayerByName[const NM: TLayerName]: TLayer read
    GetLayerByName;
  end;

{: This is a non visual control that is used to store and manage the list
   of graphic objects that defines a draw.

   TDrawing is an asbtract class use to define a common interface for
   drawing management. In fact the control is not useble by itself
   because it doesn't specify the kind of objects that can be stored,
   but only assest what kind of operation are necessary for storing
   general graphic objects.

   Basically this control is used to store a list of objects that must
   be drawed. Until you define a viewport from which see the objects
   these objects are only stored in a list that will be traversed to
   produce a draw as soon as you have defined such a viewport (see
   <See Class=TCADViewport>) by linking a viewport control to the
   TDrawing (see <See Property=TCADViewport@Drawing>).

   The first thing you must define is the kind of objects you want to
   use:

   <LI=If you want to create 2D drawings use the control
       <See Class=TDrawing2D> >
   <LI=If you want to create 3D drawings use the control
       <See Class=TDrawing3D> >

   these specific controls are derived from this one implementing
   the abstract method to handle 2D or 3D objects.

   This control handles also the PERSISTANCE of the draw, giving
   method to save and retrive the list of objects from a stream or
   a file (see <See=Object's Persistance@PERSISTANCE>). The use of polymorphism and
   class references made possible to add your own shape classes
   that will be considered as much the same as the native ones.

   Think about this control as a TDataSet for a Database application.

   <B=Note>: You don't need to derive from this control because the
   library has already the two controls you need to handle 2D and
   3D drawing. You may want to derive from this control to improve
   its list management or to implement ordered display lists for
   special 3D operation (like implementing spatial partitioning
   with BSP).
}
  TObject2DClass = class of TObject2D;
  TChangeProc = procedure(const Obj: TGraphicObject; PData: Pointer) of object;

  TDrawing = class(TComponent)
  private
    fVersion: TCADVersion;
      { The version info is used in file I/O. }
    fListOfObjects, fListOfBlocks: TGraphicObjList;
      { There are two list. The one of the objects and the one of the blocks. }
    fNextID, fNextBlockID: Integer;
      { Contain the next ID to assign. }
    fListOfViewport: TList;
      { Contains all the Viewports linked. }
    fLayers: TLayers; { Layers of the component. }
    fCurrentLayer: Word;
    fDrawOnAdd: Boolean;
      { If true the object will be drawn on all viewports and the viewports will be refreshed if an object is added. }
    fRepaintAfterTransform: Boolean;
      { Repaint all the viewports if an object will be transformed. }

    { event handlers. }
    //TSY:
    fOnChangeDrawing: TOnChangeDrawing;
    fOnAddObject: TAddObjectEvent;
    fOnVerError: TBadVersionEvent;
    fOnLoadProgress: TOnLoadProgress;
    fOnSaveProgress: TOnSaveProgress;
    fSelectedObjs: TGraphicObjList;
    fSelectionFilter: TObject2DClass;

    function GetListOfObjects: TGraphicObjIterator;
    function GetListOfBlocks: TGraphicObjIterator;
    procedure SetListOfObjects(NL: TGraphicObjList);
    procedure SetListOfBlocks(NL: TGraphicObjList);

    function GetExclusiveListOfObjects:
      TExclusiveGraphicObjIterator;
    function GetExclusiveListOfBlocks:
      TExclusiveGraphicObjIterator;
    function GetObjectsCount: Integer;
    function GetSourceBlocksCount: Integer;
    function GetIsBlocked: Boolean;
    function GetHasIterators: Boolean;
    procedure SetDefaultLayersColor(const C: TColor);
    function GetDefaultLayersColor: TColor;
    { Add the indicated Viewport. This function is automatically called by
      a Viewport so the user have no need to call it directly. }
    procedure AddViewports(const VP: TCADViewport);
    { Delete the indicated Viewport. This function is automatically called
      by a Viewport so the user have no need to call it directly. }
    procedure DelViewports(const VP: TCADViewport);
    function GetViewport(IDX: Integer): TCADViewport;
    function GetViewportsCount: Integer;
  protected
    {: This method loads the blocks definitions (see <See Class=TSourceBlock2D> and
       <See Class=TSourceBlock3D>) from a drawing.
       This is an abstract method that must be implemented in a concrete control.

       <I=Stream> is the stream that contains the blocks (and it must be
       positioned on the first block present). The stream must be
       created with the current version of the library.
       The blocks are created by reading the shape class registration index
       and creating the correct shape instance with the state present in the
       stream. Then this instance is saved in the list of objects of the
       source block.

       When a source block is loaded the objects that are contained in the
       source block are checked for recursive nesting of blocks. It is
       allowed to have a source block that use in its definition another
       source block, BUT this source block must be loaded before the
       source block that use it (this is automatically checked when you
       define a block). When the source block is loaded its
       <See Method=TContainer2D@UpdateSourceReferences>
       (<See Method=TContainer3D@UpdateSourceReferences>) is called to
       update the references.

       If there is a block that references to a not defined source block
       a message will be showed and the source block will not be loaded.

       See also <See=Object's Persistance@PERSISTANCE>.
    }
    procedure LoadBlocksFromStream(const Stream: TStream; const
      Version: TCADVersion); virtual; abstract;
    {: This method saves the blocks definitions (see <See Class=TSourceBlock2D> and
       <See Class=TSourceBlock3D>) to a drawing.
       This is an abstract method that must be implemented in a concrete control.

       <I=Stream> is the stream into which save the source blocks,
       <I=AsLibrary> tells if list of source blocks must be saved as
       a library. A Library will contains only the source blocks that
       have the <See Property=TGraphicObject@ToBeSaved> property set to
       <B=True> and the <See Property=TSourceBlock2D@IsLibraryBlock> (
       <See Property=TSourceBlock3D@IsLibraryBlock>) property set to
       <B=True>. This is useful to create library of blocks definition
       to be shared beetwen drawing.

       See also <See=Object's Persistance@PERSISTANCE>.
    }
    procedure SaveBlocksToStream(const Stream: TStream; const
      AsLibrary: Boolean); virtual; abstract;
    {: This method loads the objects saved in a drawing stream.

       <I=Stream> is the stream that contains the objects (and it must be
       positioned on the first object present). The stream must be
       created with the current version of the library.
       The objects are created by reading the shape class registration
       index and creating the correct shape instance with the state present
       in the stream. Then this instance is stored in the list of object of
       the control.

       When a block instance (see <See Class=TBlock2D> and <See Class=TBlock3D>)
       is loaded the source block reference is updated with the current list
       of source block by calling the <See Method=TBlock2D@UpdateReference>
       (<See Method=TBlock3D@UpdateReference>) method. If this source block
       is not present a message will be showed and the source object discarded.

       See also <See=Object's Persistance@PERSISTANCE>.
    }
    procedure LoadObjectsFromStream(const Stream: TStream; const
      Version: TCADVersion); virtual; abstract;
    {: This method saves the objects in the display list to a drawing stream.
       This is an abstract method that must be implemented in a concrete control.

       <I=Stream> is the stream into which save the objects.

       See also <See=Object's Persistance@PERSISTANCE>.
    }
    procedure SaveObjectsToStream(const Stream: TStream);
      virtual; abstract;
    {: This method adds a new source block.

       <I=ID> is the identifier number of the source block and Obj is the
       source block object. The library doesn't check for uniqueness of
       source block's ID. The given ID substitute the ID of Obj. A source
       block can also be referenced by its name and again the library
       doesn't check for its uniqueness.

       A source block is a collection of objects that are drawed at a whole
       on the viewport. A source block must be istantiated before the
       drawing occourse by define a block that references it. The instance
       has a position so you can share the same collection of objects and
       draw it in different places on the same drawing. This allows the
       efficent use of memory. If a source block is modified, all the
       instances are modified accordingly.

       The method returns the added block.

       See also <See Class=TSourceBlock2D>, <See Class=TSourceBlock3D>,
       <See Class=TBlock2D> and <See Class=TBlock3D>.
    }
    function AddSourceBlock(ID: Integer; const Obj:
      TGraphicObject): TGraphicObject;
    {: This method returns the source block with the given name or
       <B=nil> if no such object is found.

       The returned reference is of type <See Class=TGraphicObject>, you must
       up-cast it to the appropriate class.

       See also <See Method=TDrawing@GetSourceBlock>.
    }
    function FindSourceBlock(const SrcName: TSourceBlockName):
      TGraphicObject;
    {: This method returns the source block with the given ID or
       <B=nil> if no such object is found.

       The returned reference is of type <See Class=TGraphicObject>, you must
       up-cast it to the appropriate class.

       See also <See Method=TDrawing@FindSourceBlock>.
    }
    function GetSourceBlock(ID: Integer): TGraphicObject;
    {: This method adds a new object.

       <I=ID> is the identifier number of the object to add and Obj is the
       object to add. The library doesn't check for uniqueness of
       object's ID. The given ID substitute the ID of Obj. The object
       will be placed on the current layer (see <See Property=TDrawing@CurrentLayer>).

       The object is added after all the objects in the control, and will be
       drawed in front of them. Use <See Method=TGraphicObjList@Move> method
       on <See Property=TDrawing@ObjectList> to change the this order; or use
       <See Method=TDrawing@InsertObject> to add the object in a specified
       position in the list.

       The method returns the added object.
    }
    function AddObject(ID: Integer; const Obj: TGraphicObject):
      TGraphicObject;
    {: This method insert a new object in a given position.

       <I=ID> is the identifier number of the object to insert and Obj is the
       object to insert. The library doesn't check for uniqueness of
       object's ID. The given ID substitute the ID of Obj. The object
       will be placed on the current layer (see <See Property=TDrawing@CurrentLayer>).
       <I=IDInsertPoint> is the object's ID of the object in front of which <I=Obj>
       will be inserted. So <I=Obj> is drawed before this object and appear under it.
       The objects are drawed in the order in which they appear in the list.

       If the object with <I=IDInsertPoint> doesn't exist in the list a
       <See Class=ECADListObjNotFound> exception will be raised.

       The method returns the added object.
    }
    function InsertObject(ID, IDInsertPoint: Integer; const Obj:
      TGraphicObject): TGraphicObject;
    {: This method returns the object with the given ID or
       <B=nil> if no such object is found.

       The returned reference is of type <See Class=TGraphicObject>, you must
       up-cast it to the appropriate class before use.
    }
    function GetObject(ID: Integer): TGraphicObject;
    {: This method draw the given object on all the linked viewports.

       <I=Obj> is the object to be drawed. This object will be drawed with
       the appropriate colour on all the viewports linked to the control
       (see <See Property=TDrawing@Viewports>).

       The viewports will also be refreshed after the drawing
       (see <See Method=TCADViewport@Refresh>).
    }
    procedure RedrawObject(const Obj: TGraphicObject);
    {: This property contains the list of objects of the control.

       Use this property if you want to change the display list through
       the methods of the list of graphic objects (see <See Class=TGraphicObjList>).

       If you want to traverse the list of object use the methods
       <See Method=TDrawing@ObjectsIterator>,
       <See Method=TDrawing@ObjectsExclusiveIterator> to obtain iterators on the
       display list.

       This property is useful if you want to use an optimized list instead of the
       default one (it must be derived from <See Class=TGraphicObjList> class).
       In this case use this property just after the creation of the control and
       before adding objects to it.
    }
    property ObjectList: TGraphicObjList read fListOfObjects
      write SetListOfObjects;
    {: This property contains the list of source block of the control.

       Use this property if you want to change the display list through
       the methods of the list of graphic objects (see <See Class=TGraphicObjList>).

       If you want to traverse the list of source blocks use the methods
       <See Method=TDrawing@SourceBlocksIterator>,
       <See Method=TDrawing@SourceBlocksExclusiveIterator> to obtain iterators on the
       source block list.

       This property is useful if you want to use an optimized list instead of the
       default one (it must be derived from <See Class=TGraphicObjList> class).
       In this case use this property just after the creation of the control and
       before adding any source blocks to it.
    }
    property BlockList: TGraphicObjList read fListOfBlocks write
      SetListOfBlocks;
  public
    {: This is the constructor of the control.

       It sets the control in the following state:

       <LI=<See property=TDrawing@CurrentLayer> set to 0>
       <LI=<See property=TDrawing@DrawOnAdd> set to <B=False> >
       <LI=<See property=TDrawing@RepaintAfterTransform> set to <B=True> >
       <LI=<See property=TDrawing@DefaultLayersColor> set to <B=clBlack> >
    }
    constructor Create(AOwner: TComponent); override;
    {: This is the destructor of the control.

       It destroy the control and all the objects and source blocks present
       in its display list. After that you are not allowed to reference any
       of its objects.
    }
    destructor Destroy; override;
    {: This method loads a drawing in the current one.

       <I=Stream> is the stream that contains the drawing to merge. No
       check is made to ensure that object's IDs are unique also in
       the merged drawing nor duplicate source blocks. If the stream
       doesn't contains a valid drawing then a <See Class=ECADFileNotValid>
       exception will be raised. If the drawing was created with a
       different version that the current one the drawing will be converted or
       the event <See Property=TDrawing@OnInvalidFileVersion> will be fired.

       Use this method to mix one or more drawing in one.

       See also <See Method=TDrawing@MergeFromFile>.

       <B=Note>: If the two drawings have different layer tables, then
       the one in the draw to merge will be used.
    }
    //TSY:
    procedure AddList(const Lst: TGraphicObjList);
    procedure MergeFromStream(const Stream: TStream);
    {: This method loads a drawing from a stream.

       <I=Stream> is the stream that contains the drawing to load. If
       the stream doesn't contains a valid drawing then a
       <See Class=ECADFileNotValid>
       exception will be raised. If the drawing was created with a
       different version that the current one the drawing will be converted or
       the event <See Property=TDrawing@OnInvalidFileVersion> will be fired.

       The current drawing is abbandoned when this method is called. The
       source blocks that are not library block will be also abbandoned.

       See also <See Method=TDrawing@LoadFromFile>.
    }
    procedure LoadFromStream(const Stream: TStream);
    {: This method saves a drawing into a stream.

       <I=Stream> is the destination stream. Only the source blocks that
       are no library blocks are saved with the drawing. Only the layers
       modified will be saved with the drawing.

       See also <See Method=TDrawing@SaveToFile>.
    }
    procedure SaveToStream(const Stream: TStream);
    {: This method loads the source blocks saved to a librarian stream.

       <I=Stream> is the stream that contains the library. If
       the stream doesn't contains a valid drawing then a
       <See Class=ECADFileNotValid>
       exception will be raised. If the library file was created with a
       different version that the current one the library will be converted or
       the event <See Property=TDrawing@OnInvalidFileVersion> will be fired.

       The source blocks will be added to the current ones.
    }
    procedure LoadLibrary(const Stream: TStream);
    {: This method saves a library (a group of source blocks) into a stream.

       <I=Stream> is the destination stream. Only the source blocks that
       are library blocks are saved.

       See also <See Method=TDrawing@SaveToFile>.
    }
    procedure SaveLibrary(const Stream: TStream);
    {: This method loads a drawing in the current one.

       <I=FileName> is the file name that contains the drawing to merge. No
       check is made to ensure that object's IDs are unique also in
       the merged drawing nor duplicate source blocks. If the file
       doesn't contains a valid drawing then a <See Class=ECADFileNotValid>
       exception will be raised. If the drawing was created with a
       different version that the current one the drawing will be converted or
       the event <See Property=TDrawing@OnInvalidFileVersion> will be fired.

       Use this method to mix one or more drawing in one.

       See also <See Method=TDrawing@MergeFromStream>.

       <B=Note>: If the two drawings have different layer tables, then
       the one in the draw to merge will be used.
    }
    procedure MergeFromFile(const FileName: string);
    {: This method loads a drawing from a file.

       <I=FileName> is the file name of the file that contains the drawing
       to load. If the file doesn't contains a valid drawing then a
       <See Class=ECADFileNotValid>
       exception will be raised. If the drawing was created with a
       different version that the current one the drawing will be converted or
       the event <See Property=TDrawing@OnInvalidFileVersion> will be fired.

       The current drawing is abbandoned when this method is called. The
       source blocks that are not library block will be also abbandoned.

       See also <See Method=TDrawing@LoadFromStream>.
    }
    procedure LoadFromFile(const FileName: string);
    {: This method saves a drawing into a file.

       <I=Stream> is the destination file name of the file. Only the source
       blocks that are no library blocks are saved with the drawing. Only
       the layers modified will be saved with the drawing.

       See also <See Method=TDrawing@SaveToStream>.
    }
    procedure SaveToFile(const FileName: string);
    //TSY:
    function SaveToFile_EMF(const FileName: string): Boolean;
    procedure SaveToFile_Bitmap(const FileName: string);
    procedure SaveToFile_PNG(const FileName: string);
    {: This method deletes the source block with the specified ID.

      <I=ID> is the identification number of the source block. If no such
      block is found a <See Class=ECADListObjNotFound> exception will be raised.

      If the source block to be delete is in use (that is it is referenced
      by some <See Class=TBlock2D>, <See Class=TBlock3D> object) a
      <See Class=ECADSourceBlockIsReferenced> exception will be raised and the
      operation aborted. In this case you must delete the objects that
      reference the source block before retry.
    }
    procedure DeleteSourceBlockByID(const ID: Integer);
    {: This method deletes all the source block currently defined.

      If some of the source blocks is in use (that is it is referenced
      by some <See Class=TBlock2D>, <See Class=TBlock3D> object) a
      <See Class=ECADSourceBlockIsReferenced> exception will be raised and the
      operation aborted. In this case you must delete the objects that
      reference the source block before retry.

      This method is called when the Drawing is freed, so you may see an
      error before the application is closed that inform you that some
      source blocks are not deleted. You can simply ignore this error
      that indicate a problem in the construction of the drawing.
    }
    procedure DeleteAllSourceBlocks;
    {: This method deletes all the source blocks that were saved into
       a library stream (that is they have the property
       ToBeSaved set to true and they are not library blocks).

      Use it to delete all the source blocks that belong to a
      drawing keeping only the ones that are not saved to a stream.

      If some of the source blocks is in use (that is it is referenced
      by some <See Class=TBlock2D>, <See Class=TBlock3D> object) a
      <See Class=ECADSourceBlockIsReferenced> exception will be raised and the
      operation aborted. In this case you must delete the objects that
      reference the source block before retry.
    }
    procedure DeleteSavedSourceBlocks; virtual; abstract;
    {: This method deletes all the source blocks that are
       library stream (saved or not saved !).

      Use it to undload a library if you need this or before load
      another one.

      If some of the source blocks is in use (that is it is referenced
      by some <See Class=TBlock2D>, <See Class=TBlock3D> object) a
      <See Class=ECADSourceBlockIsReferenced> exception will be raised and the
      operation aborted. In this case you must delete the objects that
      reference the source block before retry.
    }
    procedure DeleteLibrarySourceBlocks; virtual; abstract;
    {: This method searches for an object with a given ID, and if
       found changes the layer on which it lies.

       <I=ID> is the identification number of the object;
       <I=NewLayer> is the new layer number on which the object must reside.

      If the object is not found a <See Class=ECADListObjNotFound> exception
      will be raised.
    }
    procedure ChangeObjectLayer(const ID: Integer; const
      NewLayer: Byte);
    {: This method moves an object in the display list.

       <I=IDOrigin> is the identification number of the object to be moved;
       <I=IDDestination> is the identification number of the object before which
       the object will be moved.

       This method is useful to change the order of the object. After the
       moving the object with ID equal to <I=IDOrigin> will be under the
       one with ID equal to <I=IDDestination>.

      If the object is not found a <See Class=ECADListObjNotFound> exception
      will be raised.
    }
    procedure MoveObject(const IDOrigin, IDDestination:
      Integer);
    {: This method deletes an object of the display list.

       <I=ID> is the identification number of the object to be deleted.

      If the object is not found a <See Class=ECADListObjNotFound> exception
      will be raised.
    }
    procedure DeleteObject(const ID: Integer);
    {: This method removes an object of the display list but doesn't free
       its reference.

       <I=ID> is the identification number of the object to be removed.

      If the object is not found a <See Class=ECADListObjNotFound> exception
      will be raised.
    }
    procedure RemoveObject(const ID: Integer);
    {: This method removes all the objects of the display list.
    }
    procedure DeleteAllObjects;
    {: This method repaint all the linked viewports
       (see <See Property=TDrawing@Viewports>).

       This method is useful to regenerate all the viewports that display the
       objects.
    }
    procedure RepaintViewports; virtual;
    {: This method refresh all the linked viewports
       (see <See Property=TDrawing@Viewports>).

       This method is useful to update the viewports' images without
       redraw all the objects, but simply by copying the off-screen
       buffer on the canvases.
    }
    procedure RefreshViewports; virtual;
    {: This method sets the default brush of the unmodified layers.

       <I=Brush> is the brush that will be assigned to the brush of the
       unmodified layers. The reference will be assigned (deep-copied) and
       not simply stored in the Drawing, so you have to delete it by yourself.

       This method is useful when you change the background color of the viewports
       and the default color (clWhite) will be difficul to see.
    }
    procedure SetDefaultBrush(const Brush: TBrush);
    {: This method sets the default pen of the unmodified layers.

       <I=Pen> is the pen that will be assigned to the pen of the
       unmodified layers. The reference will be assigned (deep-copied) and
       not simply stored in the Drawing, so you have to delete it by yourself.

       This method is useful when you change the background color of the viewports
       and the default color (clBlack) will be difficul to see.
    }
    procedure SetDefaultPen(const Pen: TPen);
    {: This property must be used to obtain an iterator on the display list
       of the objects.

       The reference that will be obtained must be freed when you finish to
       use it.

       See also <See Class=TGraphicObjIterator>.
    }
    procedure SelectionClear;
    procedure SelectionAdd(const Obj: TGraphicObject);
    procedure SelectionAddList(const List: TGraphicObjList);
    function SelectionRemove(const Obj: TGraphicObject):
      Boolean;
    procedure SelectAll;
    procedure SelectNext(Direction: Integer);
    procedure DeleteSelected;
    function GetSelectionExtension: TRect2D;
    function GetSelectionCenter: TPoint2D;
    procedure ChangeSelected(ChangeProc: TChangeProc; PData: Pointer);
    procedure ChangeLineKind(const Obj: TGraphicObject; PData: Pointer);
    procedure ChangeLineColor(const Obj: TGraphicObject; PData: Pointer);
    procedure ChangeHatching(const Obj: TGraphicObject; PData: Pointer);
    procedure ChangeHatchColor(const Obj: TGraphicObject; PData: Pointer);
    procedure ChangeFillColor(const Obj: TGraphicObject; PData: Pointer);
    procedure ChangeLineWidth(const Obj: TGraphicObject; PData: Pointer);
    procedure NotifyChanged;
    property ObjectsIterator: TGraphicObjIterator read
      GetListOfObjects;
    {: This property must be used to obtain an iterator on the list
       of the source blocks.

       The reference that will be obtained must be freed when you finish to
       use it.

       See also <See Class=TGraphicObjIterator>.
    }
    property SourceBlocksIterator: TGraphicObjIterator read
      GetListOfBlocks;
    {: This property must be used to obtain an exclusive iterator on the
       display list of the objects.

       The reference that will be obtained must be freed when you finish to
       use it.

       See also <See Class=TExclusiveGraphicObjIterator>.
    }
    property ObjectsExclusiveIterator:
      TExclusiveGraphicObjIterator read
      GetExclusiveListOfObjects;
    {: This property must be used to obtain an exclusive iterator on the list
       of the source blocks.

       The reference that will be obtained must be freed when you finish to
       use it.

       See also <See Class=TExclusiveGraphicObjIterator>.
    }
    property SourceBlocksExclusiveIterator:
      TExclusiveGraphicObjIterator read
      GetExclusiveListOfBlocks;
    {: This property contains the layer table of the control.
       Use it to modify the visual aspect of the objects.

       See also <See Class=TLayers>.
    }
    property Layers: TLayers read fLayers;
    {: This property is the current layer on which any object added to the
       CAD resides.

       When you add on object to the display list of the control, its layer
       will be set to the value of this property (by default 0).
       You can modify the layer of the added object by using the reference
       to the object AFTER it is added to the control.
    }
    property CurrentLayer: Word read fCurrentLayer write
      fCurrentLayer;
    {: This property contains the current version of the library.

       It is used to check the versions of the drawing files.
    }
    property Version: TCADVersion read fVersion write fVersion;
    {: This property contains the number of objects present in the display list.
    }
    property ObjectsCount: Integer read GetObjectsCount;
    {: This property contains the number of source blocks present in the source blocks list.
    }
    property SourceBlocksCount: Integer read
      GetSourceBlocksCount;
    {: This property is <B=True> when one of the lists (display list or
       source blocks list) is blocked, that is it has an active exclusive
       iterator on it.

       When a list is blocked you cannot add or remove any items from it.
       So check this property before asking for an iterator.
    }
    property IsBlocked: Boolean read GetIsBlocked;
    {: This property is <B=True> when one of the lists (display list or
       source blocks list) has an active iterator on it.

       When a list has an active iterator, you can ask for another iterator
       but not for an exclusive iterator.
       So check this property before asking for an exclusive iterator.
    }
    property HasIterators: Boolean read GetHasIterators;
    {: This property contains all the viewports that are linked to the
       control.

       A viewport is a visual components that display the world defined
       by the Drawing control. <I=Idx> is the index of the viewport from
       0 to <See Property=TDrawing@ViewportsCount> - 1.

       Use this property if you want to change some of the properties of
       the viewports that use the Drawing control or if you want to apply
       to all of them an operation.

       See also <See Class=TCADViewport>.
    }
    property Viewports[IDX: Integer]: TCADViewport read
    GetViewport;
    {: This property contains the number of viewport that are linked
       to the control.

       See also <See Class=TDrawing@Viewports>.
    }
    property ViewportsCount: Integer read GetViewportsCount;
    property SelectedObjects: TGraphicObjList read
      fSelectedObjs;
    {: This property may contain a class reference type (deriving
       from <See Class=TObject2D>) used to filter the selection.

       If the picked object doesn't derive from that class, the
       object is ignored.

       By default it is <I=TObject2D>.
    }
    property SelectionFilter: TObject2DClass read
      fSelectionFilter write fSelectionFilter;
  published
    {: If this property is <B=True> then when an object is added to the
       control it is also drawed on all the linked viewports.

       By default it is <B=False>.
    }
    property DrawOnAdd: Boolean read fDrawOnAdd write fDrawOnAdd
      default False;
    {: If this property is <B=True> then when an object is transformed
       then the linked viewports will be repainted.

       By default it is <B=False>.
    }
    property RepaintAfterTransform: Boolean read
      fRepaintAfterTransform write fRepaintAfterTransform default
      True;
    {: This property contains (and sets) the default colours for the
       pen of all the unmodified layers.

       Modified layers are unchanged.
    }
    property DefaultLayersColor: TColor read
      GetDefaultLayersColor write SetDefaultLayersColor default
      clBlack;
    {: EVENTS}
    {: This property may contain an event handler that is
       called when an object is loaded into the control.

       See also <See Type=TOnLoadProgress>.
    }
    property OnLoadProgress: TOnLoadProgress read fOnLoadProgress
      write fOnLoadProgress;
    {: This property may contain an event handler that is
       called when an object is saved into a stream.

       See also <See Type=TOnSaveProgress>.
    }
    property OnSaveProgress: TOnSaveProgress read fOnSaveProgress
      write fOnSaveProgress;
    {: This property may contain an event handler that is
       called when an object is added to the control.

       See also <See Type=TAddObjectEvent>.
    }

    //TSY:
    property OnChangeDrawing: TOnChangeDrawing read
      fOnChangeDrawing write fOnChangeDrawing;

    property OnAddObject: TAddObjectEvent read fOnAddObject write
      fOnAddObject;
    {: This property may contain an event handler that is
       called when a drawing created with an older version
       of the library is loaded.

       See also <See Type=TBadVersionEvent>.
    }
    property OnInvalidFileVersion: TBadVersionEvent read
      fOnVerError write fOnVerError;
  end;

  {: This class defines a viewport with which it is possible to render
     the contents of a CAD control. This is a visual component.

     The viewport is a 2D windows through which you can see a virtual world.
     The world is stored in a <See Class=TDrawing> control as a list (display list)
     of graphic objects. The world used here is dimension less, so this component
     is not directly usable but it defines only an abstract interface.

     Regardless the kind of world (2d, 3d or more) a viewport is always a window
     on which the world is projected. The view trasformation has two
     components:

     <LI=the first one project the world on the window plane. If the world
         is already 2D this is a simple identity transform (Projection) >
     <LI=the second one project the window plane onto a portion on the canvas
         of the control (Mapping).>

     This control defines and uses only the second component of the transformation
     (see <See Method=TCADViewport@BuildViewportTransform>). The other one is
     dimension dependent and so must be defined in derived classes.

     You manage the window position and size (that is modify the second component
     of the above transformations) using the property
     <See Property=TCADViewport@VisualRect>, that is the portion of the
     window plane that you see on the canvas of the control.
     You change the VisualRect using the zooming methods (see
     <See Method=TCADViewport@ZoomIn>, <See Method=TCADViewport@ZoomOut>,
     <See Method=TCADViewport@ZoomWindow>, <See Method=TCADViewport@ZoomToExtension>
     <See Method=TCADViewport@PanWindow> and <See Method=TCADViewport@MoveWindow>).
     All of these changes the mapping transformation (the second component explained
     above).

     A viewport use a back buffer to store the current rapresentation of the
     Drawing display list. When you start a <See Method=TCADViewport@Repaint>,
     this buffer is created and copied on the canvas of the control.
     The repaint can use a thread (painting thread) to allow the user to stop
     the operation at any time. However using a thread require some additional
     steps that require a bit of time, so it is advisable to use the thread
     (see <See Property=TCADViewport@UsePaintingThread>) only when you have
     a complex draw made up of thousand of objects.
     During the repaint process you can also copy the buffer content on the
     on screen canvas when a prestabilited number of objects (see
     <See Property=TCADViewport@CopingFrequency> property) is drawed. This
     gives a useful feedback to the user.

     See also <See Class=TCADViewport2D> and <See Class=TCADViewport3D>.
}
  TCADViewport = class(TCustomControl)
  private
    fViewGuard: TCADSysCriticalSection;
    fDrawing: TDrawing;
    fDrawMode: Cardinal;
    fVisualWindow: TRect2D;
      { The current viewport on the view plane. }
    fViewportToScreen, fScreenToViewport: TTransf2D;
      { To speed the inversion of the matrix I keep either. }
    fAspectRatio: TRealType;
    //TSY: added fControlPointsPenColor
    fRubberPenColor, fBackGroundColor, fGridColor,
      fControlPointsColor, fControlPointsPenColor: TColor;
    fRubberPen: TPen;
    { FOffScreenBitmap contain the off-screen bitmap used by the Viewport. The
      Viewport use FOffScreenBitmap to store the actual view of the draw. When
      the draw change the FOffScreenBitmap is redrawed. During a repaint the
      FOffScreenBitmap is put on the canvas. }
    fOffScreenBitmap: TBitmap;
    fOffScreenCanvas: TDecorativeCanvas;
    fOnScreenCanvas: TDecorativeCanvas;
    fCopingFrequency: Integer;
      { Indica ogni quanto copiare il buffbitmap sul canvas quando si usa il threading. }
    fShowControlPoints, fShowGrid, fInUpdate: Boolean;
    fControlPointsWidth: Byte;
    fGridDeltaX,
      fGridDeltaY,
      fGridSubX,
      fGridSubY: TRealType;
    fGridOnTop: Boolean;
    fTransparent: Boolean;
    { If fViewportObjects is nil then the component will use the Drawing. Else
      this list is used. Note: The list is not managed by the viewport. }
    fViewportObjects: TGraphicObjList;
    { Event handlers }
    fOnClear: TClearCanvas;
    fDisablePaintEvent, fDisableMouseEvents: Boolean;
    fOnPaint, fOnResize, fOnBeginRedraw, fOnEndRedraw:
    TNotifyEvent;
    fOnViewMappingChanged: TNotifyEvent;
    fOnMouseEnter, fOnMouseLeave: TNotifyEvent;

    { Multithread support. }
    fPaintingThread: TObject;
    fUseThread: Boolean;

    { Set method for the property. }
    procedure SetRubberColor(const Cl: TColor);
    procedure SetBackColor(const Cl: TColor);
    procedure SetTransparent(const B: Boolean);
    procedure SetGridColor(const Cl: TColor);
    procedure SetShowGrid(const B: Boolean);
    procedure SetOnClearCanvas(const H: TClearCanvas);
    procedure ClearCanvas(Sender: TObject; Cnv: TCanvas; const
      ARect: TRect2D; const BackCol: TColor);
    procedure DoCopyCanvas(const GenEvent: Boolean);
    procedure DoCopyCanvasThreadSafe;
    procedure CalibrateCnv(const Cnv: TCanvas; XScale, YScale:
      TRealType);
    { NEW. Cambia il mapping chiamando BuildViewportTransform. }
    procedure ChangeViewportTransform(ViewWin: TRect2D);

    { Per il thread }
    procedure StopPaintingThread;
    { Se sono in repainting lo blocco e ricomincio. }
    procedure UpdateViewport(const ARect: TRect2D);
      { repaint all the objects contained in ARect. }
    function GetInRepaint: Boolean;
    procedure DoResize;
    procedure CopyBitmapOnCanvas(const DestCnv: TCanvas; const
      BMP: TBitmap; IRect: TRect; IsTransparent: Boolean;
      TransparentColor: TColor);
    procedure SetDeltaX(const V: TRealType);
    procedure SetDeltaY(const V: TRealType);
    procedure SetSubX(const V: TRealType);
    procedure SetSubY(const V: TRealType);
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    {: This method is called at the creation of the control to
       create the decorative canvas for it. You can override it
       to use your specialized decorative canvas.

       Note that only the off screen canvas can be personalized.
    }
    function CreateOffScreenCanvas(const Cnv: TCanvas):
      TDecorativeCanvas; dynamic;
    {: This method is called when a painting thread (if used) is terminated.

       It sets the thread instance reference to nil (the thread is freed by
       itself). It also copy the backbuffer on the canvas of the control.

       See also <See Property=TCADViewport@UsePaintingThread>.
    }
    procedure OnThreadEnded(Sender: TObject); dynamic;
    {: This method copies the backbuffer image on the canvas of the control.

       <I=Rect> is the rectangle of the backbuffer to be copied on the same
       rectangle on the canvas of the control (remember that the two canvases
       have the same size); if <I=GenEvent> is <B=True> the an
       <See Property=TCADViewport@OnPaint> event will be fired after the copy.
    }
    procedure CopyBackBufferRectOnCanvas(const Rect: TRect; const
      GenEvent: Boolean); dynamic;
    {: This method sets the <See Class=TDrawing> control that contains the display list
       to be drawed.

       <I=Cad> is the control reference to which the viewport will be linked.
       If it is <B=nil> the viewport will be removed from the current CAD
       to which it is linked.

       See also <See Property=TDrawing@Viewports> property.
    }
    procedure SetDrawing(Cad: TDrawing); virtual;
    {: This method handles the WM_PAINT message of Windows.

       It firstly check to see if the dimension of the component are
       different with the ones of the back buffer canvas. In this case
       the back buffer dimensions are changed accordingly and the
       display list is rendered on it.

       After that the back buffer image is simply copied on the control
       canvas and an <See Property=TCADViewport@OnPaint> event is fired.
    }
    procedure Paint; override; { Repaint all the objects. }
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message
      WM_ERASEBKGND;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMMouseEnter(var Message: TMessage); message
      CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message
      cm_MOUSELEAVE;
    {: This method is called by the viewport whenever a changing in the
       mapping transform from window plane (view plane) and canvas
       rectangle is required.

       It must returns a 2d transform matrix that transforms the 2d points
       in the visual rect (see <See Property=TCADViewport@VisualRect>)
       in the 2d points in the client rectangle of the control Canvas.

       <I=ViewWin> is the visual rect (that is the portion of
       the world currently in view); <I=ScreenWin> is the portion of the
       control's canvas that must contains the drawing and <I=AspectRatio> is
       an optional aspect ratio (Width/Heigth) to be preserved in the mapping.

       If AspectRatio is zero then no aspect ratio is specified, otherwise the
       aspect ratio must modify the <I=ViewWin> dimensions so that they preserve
       this aspect ratio. The new ViewWin will became the <See Property=TCADViewport@VisualRect>
       of the viewport.

       You must redefine this method if you want to create a new viewport,
       for example you can also change any other projection transform when
       this method is called; by default it returns <See const=IdentityTransf2D>.

       <B=Note>: You may want to use the <See function=GetVisualTransform2D> function
       to obtain the mapping transform.
    }
    function BuildViewportTransform(var ViewWin: TRect2D; const
      ScreenWin: TRect; const AspectRatio: TRealType):
      TTransf2D;
      virtual;
    {: This method draws a 2D rectangular grid on the viewport.

       <I=ARect> is the portion of the window plane that is currently viewed in
       the control; <I=Cnv> is the canvas on which draw the grid.

       By default it draws a grid that originates in (0, 0) and has an X step
       and Y step specified by the <See Property=TCADViewport@GridDeltaX>,
       <See Property=TCADViewport@GridDeltaY> properties.
    }
    procedure DrawGrid(const ARect: TRect2D; const Cnv:
      TCanvas);
      virtual;
    {: This method draws an object on a canvas, by transforming it with the
       view transform.

       This method must be specilized to manages the objects of the correct type
       in the display list. This method then calls the appropriate drawing
       method of the specialized object. You have also to check for
       visibility in this method, to reduce the time of drawing.

       Before any drawing takes place the Canvas is modified with the
       object's layer properties.

       <I=Obj> is the object to be drawed and <I=Cnv> is the canvas on
       which to draw the object. <I=ClipRect2D> is the clipping rectangle
       in 2D coordinates (of the canvas).
    }
    procedure DrawObject(const Obj: TGraphicObject; const Cnv:
      TDecorativeCanvas; const ClipRect2D: TRect2D); virtual;
      abstract;
    procedure DrawObjectControlPoints(const Obj: TGraphicObject;
      const Cnv: TDecorativeCanvas; const ClipRect2D: TRect2D);
      virtual; abstract;
    {: This method draws an object on a canvas, by transforming it with the
       view transform.

       This method must be specilized to manages the objects of the correct type
       in the display list. This method then calls the appropriate drawing
       method of the specialized object. You have also to check for
       visibility in this method, to reduce the time of drawing.

       The object is drawed with the <See Property=TCADViewport@RubberPen>
       pen. This is useful when you want to simulate the rubber band method
       , so when the same object is drawed twice the second time remove the
       object from the canvas leaving it as it was before any draw taken place.
       This is the default beaviour. See the <See Property=TCADViewport@RubberPenColor>
       property for a way to change the color of the rubber pen.

       The method draws also the control points of the object if any control
       points is defined.

       <I=Obj> is the object to be drawed and <I=Cnv> is the canvas on
       which to draw the object. <I=ClipRect2D> is the clipping rectangle
       in 2D coordinates.
    }
    procedure DrawObjectWithRubber(const Obj: TGraphicObject;
      const Cnv: TDecorativeCanvas; const ClipRect2D: TRect2D);
      virtual; abstract;
    {: This method copy a portion of the back buffer canvas on another canvas.
       It is useful to copy the drawing in the clipboard or to print it.

       <I=CADRect> is the portion (in view plane coordinates) of the view plane
       that must be copied; <I=CanvasRect> is the rectangle into which copy that
       portion and <I=Cnv> is the destination canvas. <I=CopyMode> specify the
       type of the copy (see <See Type=TCanvasCopyMode>).
    }
    procedure CopyRectToCanvas(CADRect: TRect2D; const
      CanvasRect: TRect; const Cnv: TCanvas; const Mode:
      TCanvasCopyMode); virtual; abstract;
    {: This method returns the mapping transform matrix that is used by the
       <See Method=TCADViewport@CopyRectToCanvas> method to copy a portion of
       the back buffer canvas on another canvas.

       <I=CADRect> is the portion (in view plane coordinates) of the view plane
       that must be copied; <I=CanvasRect> is the rectangle into which copy that
       portion and <I=Cnv> is the destination canvas. <I=CopyMode> specify the
       type of the copy (see <See Type=TCanvasCopyMode>).
    }
    function GetCopyRectViewportToScreen(CADRect: TRect2D; const
      CanvasRect: TRect; const Mode: TCanvasCopyMode):
      TTransf2D;
      virtual;
    {: This method returns the mapping transform matrix that maps the
       visual rect portion of the view plane in the client area of the
       control.

       You may want to use it to mimics viewport view transform. For
       instance with this transformation you can found where a point in
       viewplane coordinates will be transformed on the control's canvas.

       <B=Note>: This matrix models only the mapping part of the view
       transformation. You may also want to add the projection part, that
       is viewport dependent.
    }
    function GetViewportToScreen: TTransf2D; virtual;
    {: This method returns the invers of the mapping transform matrix that
       maps the client area of the control in the visual rect portion of
       the view plane.

       You may want to use it to mimics viewport view transform. For
       instance with this transformation you can found where a point in
       canvas of the control will be transformed in the view plane.

       <B=Note>: This matrix models only the mapping part of the view
       transformation. You may also want to add the projection part, that
       is viewport dependent.
    }
    function GetScreenToViewport: TTransf2D; virtual;
    {: This method returns the width of a pixel in world coordinates.
       This method is used
       by the <See Method=TCADViewport2D@PickObject> (<See Method=TCADViewport3D@PickObject>)
       method.

       The point returned must be interpreted as:

       <LI=The X coordinate of the point rapresent the width of the square
       into which a pixel is transformed by the viewport.>
       <LI=The Y coordinate of the point rapresent the height of the square
       into which a pixel is transformed by the viewport.>
    }
    procedure Notification(AComponent: TComponent; Operation:
      TOperation); override;

    {: The back-buffer bitmap. }
    property OffScreenBitmap: TBitmap read fOffScreenBitmap;
  public
    { Public declarations }
    ShowRulers: Boolean;
    {: This is the constructor of the control.

       It creates a new viewport with the following properties:

       <LI=<See Property=TCADViewport@VisualRect> is set to (0, 0)-(100, 100)>
       <LI=<See Property=TCADViewport@DisableMouseEvents> is set to <B=False> >
       <LI=<See Property=TCADViewport@DisableRepaintEvents> is set to <B=False> >
       <LI=<See Property=TCADViewport@AspectRatio> is set to 0.0>
       <LI=<See Property=TCADViewport@RubberPenColor> is set to clRed>
       <LI=<See Property=TCADViewport@BackGroundColor> is set to clSilver>
       <LI=<See Property=TCADViewport@GridColor> is set to clGray>
       <LI=<See Property=TCADViewport@GridDeltaX> is set to 10>
       <LI=<See Property=TCADViewport@GridDeltaY> is set to 10>
       <LI=<See Property=TCADViewport@ControlPointsWidth> is set to 4>
       <LI=<See Property=TCADViewport@ControlPointsColor> is set to <B=clRed> >
       <LI=<See Property=TCADViewport@ShowControlPoints> is set to <B=True> >
       <LI=<See Property=TCADViewport@ShowGrid> is set to <B=True> >
       <LI=<See Property=TCADViewport@UsePaintingThread> is set to <B=False> >
       <LI=<See Property=TCADViewport@CopingFrequency> is set to 100>
    }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {: This method forces to rebuild the mapping tranform.

       When the visual rect change this method will be called and the
       viewport repainted. If you want to force the mapping tranform
       to be updated call this method (this is useful when you derive a
       new viewport that has its own projection transform).
    }
    procedure UpdateViewportTransform;
    {: This method scale the visual rect to correspond to a speficied
       dimension in millimeters.

       <I=XScale> is the horizontal scale so that 1 drawing unit
       will be 1/XScale millimeters, <I=YScale> is the vertical scale
       so that 1 drawing unit will be 1/YScale millimeters. For example
       if XScale=2 then a rectangle wide 50 drawing units will be
       25 mm wide.

       <B=Note>: The method relies on the Windows setting for
       HORZRES and VERTRES of a device. Some times (this is true
       most of the time for a screen) these values are not
       correctly set and so the resulting drawing might have
       an incorrect dimension.
    }
    procedure Calibrate(const XScale, YScale: TRealType);
    {: This method set the visual rect to a specified rectangle.

       <I=NewWindow> is the new visual rect. This correspond to
       zoom the viewport to a specified portion of the view plane.
       The rectangle is in view plane coordinates.
    }
    procedure ZoomWindow(const NewWindow: TRect2D);
    {: This method moves the current visual rect to a specified
       position.

       <I=NewStartX> is the new X position of the lower-left corner
       of visual rect; <I=NewStartY> is the new y position of the lower-left corner
       of visual rect.

       The two coordinates are referred to view plane coordinates.
    }
    procedure MoveWindow(const NewStartX, NewStartY: TRealType);
    {: This method enlarges the current visual rect.

       The actual visual rect is doubled on both X and Y directions,
       resulting in a magnification of the current view of the drawing.
    }
    procedure ZoomCenter(const C: TPoint2D; const F: TRealType);
    procedure ZoomFrac(const FX, FY: TRealType; const F: TRealType);
    procedure ZoomSelCenter(const F: TRealType);
    procedure ZoomViewCenter(const F: TRealType);
    procedure ZoomIn;
    {: This method reduces the current visual rect.

       The actual visual rect is halfed on both X and Y directions,
       resulting in a reduction of the current view of the drawing.
    }
    procedure ZoomOut;
    {: This method zooms the drawing so that all of it is visible.

       Because the extension of a drawing depends on the dimension of
       it (2d, 3d and so on), this is an abstract method that must be
       implemented in all derived components (if applicable).

       <B=Note>: if the aspect ratio of the viewport is specified then
       the visual rect may be greater than the extension of the drawing.
    }
    procedure ZoomToExtension; virtual; abstract;
    {: This method pans the visual rect by a specified ammount in
       both X and Y directions.

       <I=DeltaX> is the ammount of pan in the X direction and
       <I=DeltaY> is the ammount of pan in the Y direction. Both
       of them are specified in view plane coordinates.
    }
    procedure PanWindow(const DeltaX, DeltaY: TRealType);
    procedure PanWindowFraction(const FX, FY: TRealType);
    procedure CopyToCanvasBasic(const Cnv: TCanvas;
      const Rect: TRect); virtual;
    {: This method copy the current viewport contents in another canvas.

       <I=Cnv> is the destination canvas; <I=Mode> is the mode of the
       copy (see <See Type=TCanvasCopyMode>); <I=View> is the view to
       be copied (see <See Type=TCanvasCopyView>); <I=XScale> and
       <I=YScale> are used only if <I=View> is <I=cvScale> and have
       the same meaning of <I=XScale> and <I=YScale> of the
       <See Method=TCADViewport@Calibrate> method.

       The diplay list is traversed and the objects are drawed onto
       the destination canvas. This method is useful to copy the
       current view (or the extension of the drawing) to the clipboard
       as a bitmap or metafile (depending on the type of canvas) picture.
       It is also useful in printing the drawing on the printer, when
       the destination canvas is the canvas of the printer.

       See also <See Method=TCADViewport@CopyToClipboard>.
    }
    procedure CopyToCanvas(const Cnv: TCanvas; const Mode:
      TCanvasCopyMode; const View: TCanvasCopyView; const
      XScale, YScale: TRealType); virtual;
    {: This method copy the current viewport contents to the clipboard.

       The backbuffer is copied into the clipboard as a bitmap data.

       See also <See Method=TCADViewport@CopyToCanvas>.
    }
    //TSY:
    function AsMetafile: TMetaFile;
    function AsBitmap: TBitmap;
    procedure CopyToClipboard;
    {: This method start a group of updates so that only one repainting
       of the viewport take place at the end of the group.

       Normally the viewport is repainted as soon as the visual rect is
       changed. If you want to perform a group of such changes to obtain
       a special visual rect, the viewport is repainted a lot of times,
       reducing the performance of your application (specially if the
       drawing is complex). To resolve this problem you may want to call
       this method just before starting to changes to the visual rect, and
       then calling <See Method=TCADViewport@EndUpdate> to end the group.
       When you call <See Method=TCADViewport@EndUpdate> the visual rect is
       changed and the viewport is repainted. Only one
       <See Property=TCADViewport@OnPaint> event is fired.
    }
    procedure BeginUpdate;
    {: This method end a group of updates so that only one repainting
       of the viewport take place at the end of the group.

       Normally the viewport is repainted as soon as the visual rect is
       changed. If you want to perform a group of such changes to obtain
       a special visual rect, the viewport is repainted a lot of times,
       reducing the performance of your application (specially if the
       drawing is complex). To resolve this problem you may want to call
       <See Method=TCADViewport@BeginUpdate> just before starting to changes to
       the visual rect, and then calling this method to end the group.
       When you call this method the visual rect is
       changed and the viewport is repainted. Only one
       <See Property=TCADViewport@OnPaint> event is fired.
    }
    procedure EndUpdate;
    {: This method repaints the viewport contents.

       When you call this method the display list, of the <See Class=TDrawing>
       control associated to the viewport, is traversed and the objects contained
       in it are drawed on the viewport's off-screen buffer.

       At the end of the traversion a <See Property=TCADViewport@OnPaint> event
       is fired.

       The redrawing process cannot be interrupted if you don't use a
       painting thread. If you use it then you can interrupt the process
       by calling <See Method=TCADViewport@StopRepaint>. However if you
       use a painting thread the process takes a longer time.
    }
    procedure Repaint; override;
    procedure Invalidate; override;
    {: This method refreshes the viewport contents.

       The refresh consist of a copy of the off screen buffer on the
       canvas of the control. This refresh is very useful to remove
       spurious drawings of objects drawed directly on the canvas of
       the control.

       This process is faster than repainting the viewport but
       don't reflect changing in the objects already drawed by a repaint.
    }
    procedure Refresh;
    {: This method repaints a partion of the visual rect.

       <I=ARect> is the portion of the visual rect to be repainted.
       When you call this method the display list, of the <See Class=TDrawing>
       control associated to the viewport, is traversed and the objects contained
       , also partially, in the <I=ARect> portion of the visual rect
       are drawed on the viewport's off-screen buffer.

       At the end of the traversion a <See Property=TCADViewport@OnPaint> event
       is fired.

       The redrawing process cannot be interrupted if you don't use a
       painting thread. If you use it then you can interrupt the process
       by calling <See Method=TCADViewport@StopRepaint>. However if you
       use a painting thread the process takes a longer time.
    }
    procedure RepaintRect(const ARect: TRect2D);
    {: This method refreshes a portion of the viewport contents.

       The refresh consist of a copy of the off screen buffer on the
       canvas of the control. This refresh is very useful to remove
       spurious drawings of objects drawed directly on the canvas of
       the control. Only the portion specified by <I=ARect> is
       copied.

       This process is faster than repainting the viewport but
       don't reflect changing in the objects already drawed by a repaint.
    }
    procedure RefreshRect(const ARect: TRect);
    {: This method interrupts a repaint process.

       Only if you are using the painting threads this method is
       able to interrupt a repaint process. Otherwise it does nothing.
    }
    procedure StopRepaint;
    {: Wait for the painting thread to be finished.

       When you use the painting thread to repaint the viewport, you
       may want to wait for it to be finished. This method returns
       only when the active painting thread (if any) is finished.

       If you don't use the painting threads to repaint the viewport
       this method does nothing.
    }
    procedure WaitForRepaintEnd;
    {: This method returns the 2D point in view plane coordinates that
       correspond to the specified point in Windows screen coordinates.

       <I=SPt> is the 2D point in Windows screen coordinates to be
       transformed. It is of type <See Type=TPoint2D> but in fact it
       corresponds to a TPoint. Use <See function=PointToPoint2D>
       function to obtain this value.

       This method is useful to mimics the viewport mapping to the screen.
    }
    function ScreenToViewport(const SPt: TPoint2D): TPoint2D;
      virtual;
    {: This method returns the point in Windows screen coordinates
       that correspond to a specified point in view plane coordinates.

       <I=WPt> is the 2D point in view plane coordinates to be
       transformed. The resulting point is of type <See Type=TPoint2D>
       but in fact it corresponds to a TPoint. Use <See function=Point2DToPoint>
       function to obtain the TPoint value from the result.
    }
    function ViewportToScreen(const WPt: TPoint2D): TPoint2D;
      virtual;
    {: This method returns the width of a square in pixel in view plane coordinates.
       This method is used
       by the <See Method=TCADViewport2D@PickObject> (<See Method=TCADViewport3D@PickObject>)
       method.

       <I=L> is the width of the square in pixel that must be trasformed in
       view plane coordinates.
    }
    function GetPixelAperture: TPoint2D; virtual;
    function GetAperture(const L: Word): TRealType;
    {: This method sets the viewport with the settings of the specified
       layer.

       The method returns <B=True> if the layer is visible.
    }
    function SetLayer(const L: TLayer): Boolean;
    {: This property contains the <See Class=TDrawing> control that
       acts as the source for the drawing to be painted in the
       viewport.

       The Drawing contains the display list of the drawing that will
       be rendered in the canvas of the viewport control.

       You must assign it before using the viewport.
    }
    //TSY:
    //function GetPixelSizeX: TRealType;
    //function GetPixelSizeY: TRealType;
    property Drawing: TDrawing read fDrawing write SetDrawing;
    {: This property contains the off screen canvas used to
       store the drawing before copying it to the canvas of the
       control.

       By using an off screen buffer the flickering is greatly
       reduced.

       See also <See Class=TDecorativeCanvas@TDecorativeCanvas>.
    }
    property OffScreenCanvas: TDecorativeCanvas read
      fOffScreenCanvas;
    {: This property contains the on-screen canvas used to
       draw directly on screen.

       See also <See Class=TDecorativeCanvas@TDecorativeCanvas>.
    }
    property OnScreenCanvas: TDecorativeCanvas read
      fOnScreenCanvas;
    {: This property contains the mapping transform from the
       view plane coordinate system to the Windows screen coordinate
       system.

       This transform matrix is computed in the
       <See Method=TCADViewport@BuildViewportTransform> method.
    }
    property ViewportToScreenTransform: TTransf2D read
      GetViewportToScreen;
    {: This property contains the mapping transform from the
       Windows screen coordinate system to the view plane coordinate system.

       This transform matrix is computed as the inverse of the
       transform returned by the
       <See Method=TCADViewport@BuildViewportTransform> method.
    }
    property ScreenToViewportTransform: TTransf2D read
      GetScreenToViewport;
    {: This property contains the portion of the view plane that is
       rendered in the canvas of the control.

       Only the objects contained in this portion of the plane are
       drawed on the screen (by using clipping).
    }
    property VisualRect: TRect2D read fVisualWindow write
      ZoomWindow;
    {: This property may contains a <See Class=TGraphicObjList> instance
       to be used instead of the display list of the associated TDrawing
       control.

       If this property references an instance then it will be used
       in the <See Method=TCADViewport@Repaint> method. Otherwise the
       object's list of the associated TDrawing is used.
    }
    property ViewportObjects: TGraphicObjList read
      fViewportObjects write fViewportObjects;
    {: This property is <B=True> when the viewport is inside an
       update block.

       See also <See Method=TCADViewport@BeginUpdate> and
       <See Method=TCADViewport@EndUpdate>.
    }
    property InUpdating: Boolean read fInUpdate;
    {: This property is <B=True> when the viewport is traversing the
       diplay list.

       When you call the <See Method=TCADViewport@Repaint> method this
       property becames <B=True>.
    }
    property InRepainting: Boolean read GetInRepaint;
    {: This property is used to inhibit the mouse events fired by the
       viewport.

       If it is <B=False> (the default) the mouse event are fired by
       the control, otherwise they are not.
    }
    property DisableMouseEvents: Boolean read fDisableMouseEvents
      write fDisableMouseEvents;
    {: This property is used to inhibit the repaint event fired by the
       viewport when it has repainted.

       If it is <B=False> (the default) the <See Property=TCADViewport@OnPaint>
       event is fired when the repaint process is finished, otherwise it is not.
    }
    property DisableRepaintEvents: Boolean read
      fDisablePaintEvent write fDisablePaintEvent;
    {: This property may contains an integer value that is passed
       to the drawing methods of the graphics object being rendered on
       the viewport.

       This is used to change the way in which the objects are drawed
       (for instance backface culled, only bounding boxes and so on).

       Normally this value contains a bit field that is checked by
       the object.
    }
    property DrawMode: Cardinal read fDrawMode write fDrawMode;
    {: This property contains the pen istance used in the rubber
       pen method.

       When the <See Method=TCADViewport@DrawObjectWithRubber> method
       is called the canvas on which draw the object is set with
       this pen. By default this method contains a pen with the
       style property equal to <B=psXOr> and color <B=clRed>.

       See also <See Property=TCADViewport@RubberPenColor> to change the
       color of the pen.
    }
    property RubberPen: TPen read fRubberPen;
  published
    { Published declarations }
    property Align;
    property Enabled;
    property Visible;
    property PopupMenu;
    property Height default 50;
    property Width default 50;
    {: This property contains the aspect ratio of the viewport.

       The aspect ratio is the ratio Width/Heigth of the visual rect
       that must be preserved.

       If it is 0.0 (the default) no aspect ration is preserved and
       the visual rect may take any shape. Otherwise the visual rect
       is forced to have the given aspect ratio.

       <B=Note>: This aspect is not the one of the screen that is taken
       into account automatically.
    }
    property AspectRatio: TRealType read fAspectRatio write
      fAspectRatio;
    {: This property contains the color of the <See Property=TCADViewport@RubberPen>
       pen.

       This color take into account the fact that the rubber pen is in
       XOr style.

       By default it is <B=clRed>.
    }
    property RubberPenColor: TColor read fRubberPenColor write
      SetRubberColor default clRed;
    {: This property contains the filling color of the control
       points.

       By default it is <B=clRed>.
    }
    property ControlPointsColor: TColor read fControlPointsColor
      write fControlPointsColor default clWhite;
    property ControlPointsPenColor: TColor read
      fControlPointsPenColor write fControlPointsPenColor default
      clNavy;

    {: This property contains the color of the background of the viewport.

       By default it is <B=clWhite>.
    }
    property BackGroundColor: TColor read fBackGroundColor write
      SetBackColor default clWhite;
    {: This property contains the color of reference grid of the viewport.

       By default it is <B=clMoneyGreen>.
    }
    property GridColor: TColor read fGridColor write SetGridColor
      default clMoneyGreen;
    {: This property specify the Z-order of the grid respect to
       the drawing. If it is false (the default) the grid will be
       drawed before any other shape and so will be covered by
       the drawing, otherwise it will be on top.
    }
    property GridOnTop: Boolean read fGridOnTop write fGridOnTop
      default False;
    {: This property contains the main step of the reference grid along
       the X axis.

       The grid property is now subdivided in four different parts:
       - GridDeltaX, GridDeltaY are equivalent to the old GridStep property
       - GridSubX, GridSubY are the number of subdivision of GridDelta?

       For example the following configuration:
       - GridDeltaX=10, GridDeltaY=10, GridSubX=5, GridSubY=5
       means a grid with a step of 10units along X and Y, and every 2
       units a dotted line.
    }
    property GridDeltaX: TRealType read fGridDeltaX write
      SetDeltaX;
    {: This property contains the main step of the reference grid along
       the Y axis.

       The grid property is now subdivided in four different parts:
       - GridDeltaX, GridDeltaY are equivalent to the old GridStep property
       - GridSubX, GridSubY are the number of subdivision of GridDelta?

       For example the following configuration:
       - GridDeltaX=10, GridDeltaY=10, GridSubX=5, GridSubY=5
       means a grid with a step of 10units along X and Y, and every 2
       units a dotted line.
    }
    property GridDeltaY: TRealType read fGridDeltaY write
      SetDeltaY;
    {: This property contains the sub step of the reference grid along
       the X axis.

       The grid property is now subdivided in four different parts:
       - GridDeltaX, GridDeltaY are equivalent to the old GridStep property
       - GridSubX, GridSubY are the number of subdivision of GridDelta?

       For example the following configuration:
       - GridDeltaX=10, GridDeltaY=10, GridSubX=5, GridSubY=5
       means a grid with a step of 10units along X and Y, and every 2
       units a dotted line.
    }
    property GridSubX: TRealType read fGridSubX write SetSubX;
    {: This property contains the sub step of the reference grid along
       the Y axis.

       The grid property is now subdivided in four different parts:
       - GridDeltaX, GridDeltaY are equivalent to the old GridStep property
       - GridSubX, GridSubY are the number of subdivision of GridDelta?

       For example the following configuration:
       - GridDeltaX=10, GridDeltaY=10, GridSubX=5, GridSubY=5
       means a grid with a step of 10units along X and Y, and every 2
       units a dotted line.
    }
    property GridSubY: TRealType read fGridSubY write SetSubY;
    {: An object can have control points. This property sets the
       dimension in pixels of these control points when they are
       drawed.
    }
    property ControlPointsWidth: Byte read fControlPointsWidth
      write fControlPointsWidth default 7;
    {: An object can have control points. If this property is <B=True> the
       control points are drawed with the object (if it has them).
    }
    property ShowControlPoints: Boolean read fShowControlPoints
      write fShowControlPoints default False;
    {: If this property is <B=True> the reference grid of the viewport
       will be drawed.
    }
    property ShowGrid: Boolean read fShowGrid write SetShowGrid
      default False;
    {: If this property is <B=True> a painting thread is used for
       the repaint process.

       The library can use a thread for the traversing of display list.
       Such a painting thread is a specilized process that runs parallel to
       the main thread of the application. A viewport can have only one
       running thread that can be interrupted at any moment by calling the
       <See Method=TCADViewport@StopRepaint>.

       Different viewports can have their own threads running
       concurrently, fasting the repainting process. They are also useful
       to allow the user to change the view parameters dinamically in
       real time.

       However when a painting thread is used, the repaint process take
       more time than if the thread use is disabled. For this the use
       of a painting thread is advisable only when there are more than
       an hundred of object to be drawed.

       By default it is <B=False>.
    }
    property UsePaintingThread: Boolean read fUseThread write
      fUseThread default False;
    {: If this property is <B=True> the the viewport will be transparent.

       By default it is <B=False>.

      <B=Note>: the transparency is avaiable only at run-time.
    }
    property IsTransparent: Boolean read fTransparent write
      SetTransparent default False;
    {: This property contains the number of objects that are drawed
       before the off screen buffer is copied onto the canvas of the
       control.

       By default its value is 100.

       Lower values make the repainting process slower.
    }
    property CopingFrequency: Integer read fCopingFrequency write
      fCopingFrequency default 0;
    {: This property may contain an event handler that is called
       just before a repaint operation is being started.
    }
    property OnBeginRedraw: TNotifyEvent read fOnBeginRedraw
      write fOnBeginRedraw;
    {: This property may contain an event handler that is called
       called after a repaint is finished (after the coping of the back buffer
       onto the on screen canvas).

       This event is fired before the <See Property=TCADViewport@OnPaint> event.
    }
    property OnEndRedraw: TNotifyEvent read fOnEndRedraw write
      fOnEndRedraw;
    {: This property may contain an event handler that is called
       after the back buffer is copied onto the on screen canvas.

       This event is fired after the <See Property=TCADViewport@OnEndRedraw>
       event.
    }
    property OnPaint: TNotifyEvent read fOnPaint write fOnPaint;
    {: This property may contais an event handler that is called
       when the dimensions of the control are changed (and the
       off screen buffer is changed accordingly).

       The event is fired after the dimensions and the mapping
       trasforms are updated but before the repaint process take
       in place (and so before the
       <See Property=TCADViewport@OnPaint> event).
    }
    property OnResize: TNotifyEvent read fOnResize write
      fOnResize;
    {: This property may contains an event handler that is called when
       the view mapping transform is changed.

       This event is fired before the <See Property=TCADViewport@OnPaint> event.

       See also <See Method=TCADViewport@BuildViewportTransform>.
    }
    property OnViewMappingChanged: TNotifyEvent read
      fOnViewMappingChanged write fOnViewMappingChanged;
    property OnEnter;
    property OnExit;
    property OnMouseEnter: TNotifyEvent read fOnMouseEnter write
      fOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read fOnMouseLeave write
      fOnMouseLeave;
    property OnDblClick;
    property OnKeyDown;
    property OnKeyUp;
    property OnKeyPress;
    {: This property may contains an event handler that is called when
       the off screen buffer must be cleared before the drawing process.

       By default the off screen buffer is cleared with an uniform
       filling with the <See Property=TCADViewport@BackgroundColor> color.

       See also <See Type=TClearCanvas>.
    }
    property OnClearCanvas: TClearCanvas read fOnClear write
      SetOnClearCanvas;
  end;

  {: This class defines a ruler that can be linked to a Viewport to
     show the extension of its <See Property=TCADViewport@VisualRect>.

     The components isn't updated automatically, instead it defines
     methods that must be called from the application to keep it
     syncronized with the viewport.

     Normally the following events are used for updating the ruler:

     <LI=<I=OnEndRepaint> is used to redraw the ruler and to update
     its dimensions.>
     <LI=<I=OnMouseMove> is used to update the mark position on the
     ruler <See Method=TRuler@SetMark>.>
  }
  TRuler = class(TCustomControl)
  private
    fOwnerView: TCADViewport;
    fStepSize: TRealType;
    fFontSize, FSize, fStepDivisions: Integer;
    fOrientation: TRulerOrientationType;
    fTicksColor: TColor;

    procedure SetTicksColor(C: TColor);
    procedure SetOwnerView(V: TCADViewport);
    procedure SetOrientation(O: TRulerOrientationType);
    procedure SetSize(S: Integer);
    procedure SetFontSize(S: Integer);
    procedure SetStepSize(S: TRealType);
    procedure SetStepDivisions(D: Integer);
  protected
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message
      WM_ERASEBKGND;
  public
    {: This is the constructor of the control.

       It creates a vertical white ruler with size of 20 and
       a step division of 5.
    }
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    {: This method is used to move the position marker of the ruler.

       A ruler may have a position marker that is used to show the
       current viewport position on the ruler.

       <I=Value> is the position on the ruler of the mouse in view
       plane reference coordinate. The value to be passed depends
       on the orientation of the ruler. For example a vertical ruler
       may want to show the Y coordinates of the current mouse
       position on the view plane.
    }
    procedure SetMark(Value: TRealType);
  published
    property Align;
    {: This property contains the linked viewport used for the alignment
       of the ruler

       The ruler adjust its range by using the <See Property=TCADViewport@VisualRect>
       property.
    }
    property LinkedViewport: TCADViewport read fOwnerView write
      SetOwnerView;
    {: This property contains the background color used to paint the
       ruler background.

       By default its value is clWhite.
    }
    property Color default clWhite;
    {: This property contains the color of the thick mark used to
       show the step division of the ruler.

       By default it is clBlack.
    }
    property TicksColor: TColor read fTicksColor write
      SetTicksColor default clBlack;
    {: This property contains the orientation of the ruler.

       See <See Type=TRulerOrientationType> for details.

       By default it is <I=otVertical>.
    }
    property Orientation: TRulerOrientationType read fOrientation
      write SetOrientation default otVertical;
    {: This property contains the step between two ticks. If the
       zoom is too close, this value is automatically adjusted so the
       ticks are always visible.

       By default it is 20.
    }
    property StepSize: TRealType read fStepSize write
      SetStepSize;
    {: This property defines the division on the ruler. The
       division are showed with a large tick and with the number of
       its value.

       By default it is 5.
    }
    property StepDivisions: Integer read fStepDivisions write
      SetStepDivisions default 5;
    {: This property contains the width (height) of the vertical
       (horizontal) ruler.

       If the value is small it will be difficulty to read the values
       of the divisions.

       By default it is 20.
    }
    property Size: Integer read FSize write SetSize default 20;
    {: This property contains the size of the font used to show
       the values of the divisions.

       By default it is 6.
    }
    property FontSize: Integer read fFontSize write SetFontSize
      default 6;
  end;

  {: This class defines an object that can be used to extend the handling function
     of a 2D shape object. The methods <I=DrawControlPoints> and <I=OnMe> of the class
     are called to respectively to shows the control points (handling points) and
     to returns picking information.
     For instance it is possible to defines handlers to move, rotate objects and
     so on, having them active in different moments allowing different manipulation
     modes on the same shape.

     At the moment only the old way to edit shapes is defined, but it is now more
     easy to add other way to handle shapes.

     An handler can be reused among different shapes or have it associated
     on a particular shape (in this case the HandledObject property will
     be the same as the associated shape.
  }
  TObject2DHandler = class(TObject)
  private
    fHandledObject: TObject2D;
    fRefCount: Integer;
  public
    {: This constructor create a new handler and link it to AObject.
       After the creation of the handler it is possible to show the control points
       defined by the handler and to operate on it.

       <I=AObject> will assume ownership of the handler and so you don't have to
       free it by yourself (it is deleted when the linked object is deleted or
       the handler is unlinked from the shape).

       <B=NOTE>: You will use the <See Class=TObject2D@SetHandler> method to create and
       link the handler to a 2D shape object.
    }
    constructor Create(AObject: TObject2D);
    procedure FreeInstance; override;
    destructor Destroy; override;
    {: This method is called by the library when it is necessary to show the control
       points.

       An 2D object may have a set of points that are called
       <I=control points> and that control the shape of the
       object. For example a circle may have two control points;
       the center of the circle and a point on the circle that
       specify the radious of it. At the same time it is possible to have
       control points (or better handling points) to operate on an object, like
       a baricentric handler used to move the object.

       <I=VT> is the the mapping transform that can be obtained
       with the <See Property=TCADViewport@ViewportToScreenTransform> property.
       <I=Cnv> is the canvas on which draw the control points, and
       <I=Width> is the width in pixel of the control points (that are
       drawed as a square).
    }
    procedure DrawControlPoints(const Sender: TObject2D; const
      VT: TTransf2D; const Cnv: TDecorativeCanvas; const Width:
      Integer); dynamic; abstract;
    {: This returns the part of the object that is picked by a point.

       <I=Pt> is the picking point, <I=Aperture> is the picking aperture
       and <I=Distance> will contains the distance from <I=Pt> to
       the object.

       The method must returns one of these values (ordered from the highest
       priority to the lowest priority):

       <LI=<I=PICK_NOOBJECT> if <I=Pt> is not on the object. Distance
       will became <See const=MaxCoord>.>
       <LI=<I=PICK_INBBOX> if <I=Pt> is inside the bounding box of the
       object. Distance will be equal to Aperture.>
       <LI=<I=PICK_ONOBJECT> if <I=Pt> is on the outline of the object
       with a distance less than Aperture. Distance will be that
       distance.>
       <LI=<I=PICK_INOBJECT> if <I=Pt> is inside the outline of the
       object. Distance will be set to Aperture.>
       <LI=A value greater than or equal to zero if <I=Pt> is on any of
       the control points, in this case the resulting value is that
       control point. Distance will be the distance form the control
       point.
       <LI=A value between -100 and -3. Use this range to define your specific
       pick values to use in your operation tasks.>

       You must use this convention in your implementations of
       the method. (You can use the inherited method if some of these
       condition is the same as in the base class).
    }
    function OnMe(const Sender: TObject2D; PT: TPoint2D;
      Aperture: TRealType; var Distance: TRealType): Integer;
      dynamic; abstract;
    {: This property contains the handled object of the handler.

       If this property is nil the handler is shared among different
       shapes.
    }
    property HandledObject: TObject2D read fHandledObject;
  end;

  TObject2DHandlerClass = class of TObject2DHandler;

  {: A <I=2D graphic object> is a graphic object that is defined on
     a 2D plane.

     The 2D object is defined in a special coordinate system referred
     here as the <I=model coordinate system or model system>. When an object is used by the
     library, the world coordinate system (or world system) are
     needed instead. So the object in model system is transformed by an
     matrix transform to obtain the object in the world system.
     This transform is called the <See Property=TObject2D@ModelTransform>.
     So when an object is drawed, for example, its points are first
     transformed from model system to world system by using this matrix,
     then the view transform (that the concatenation of the
     projection matrix with the mapping matrix) tranform these points
     to obtain the points in the screen system that are easily displayed.

     The 2D object has a 2D bounding box, that is the smallest
     axis aligned rectangle that fully contains the object.
     This rectangle is always in the world coordinate system and
     so it doesn't depend on the model transform. The bounding box
     must be computed in the
     <See Property=TGraphicObject@_UpdateExtension> method that have
     to be redefined.

     The model matrix is split in two parts. The first one, called
     the <I=current model matrix>, can be removed at any time or
     can be post multiplied with a new one.

     The second one, called the <I=saved model matrix>, is stored
     permanently inside the object and can only be removed
     by using the <See Method=TObject2D@RemoveTransform> method
     or substituted with the actual model matrix with the
     <See Method=TObject2D@ApplyTransform> method.
     The actual model matrix is the concatenation of the
     <I=saved model matrix> with the <I=current model matrix> in
     this order (remember that the order of concatenation of transform matrix
     is important).

     The presence of the <I=current model matrix> is helpfull to
     create operations that transform an object interactilvely and
     that can be cancelled if they are not what the user want to do.

     <B=Note>: To save space the <I=current model matrix> and the
     <I=saved model matrix> are stored in the object only if they
     are not equal to the <See const=IdentityTransf2D> constant.
  }
  TObject2D = class(TGraphicObject)
  private
    fDrawBoundingBox: Boolean;
    //TSY:
    fHasControlPoints: Boolean;
    fBox: TRect2D;
    fHandler: TObject2DHandler;

  protected
    {: This field contains the bounding box of the object.

       A bounding box is the smallest axis aligned rectangle that fully contains the object.
       This rectangle is always in the world coordinate system and
       so it doesn't depend on the model transform. The bounding box
       must be computed in the
       <See Property=TGraphicObject@_UpdateExtension> method that have
       to be redefined.

       Use this field directly to assign the computed bunding box.
    }
    property WritableBox: TRect2D read fBox write fBox;
  public
    constructor Create(ID: Integer); override;
    destructor Destroy; override;
    constructor CreateFromStream(const Stream: TStream; const
      Version: TCADVersion); override;
    procedure SaveToStream(const Stream: TStream); override;
    procedure Assign(const Obj: TGraphicObject); override;
    {: This method transform the object with a give transformation matrix.

       The <I=T> transform matrix will be post multiplied with the
       <I=current model matrix> and the result will take the place of
       the <I=current model matrix>.

       See the <See Class=TObject2D> class for details about the
       model matrix of a 2D object.
    }
    procedure TransForm(const T: TTransf2D); dynamic;
    {: This method moves the object.

       <I=DragPt> is the base point of the movement and <I=ToPt>
       is the destination point. The <I=actual model transform> will
       be substituited with a translation matrix from <I=DragPt> to
       <I=ToPt>.
    }
    procedure MoveTo(ToPt, DragPt: TPoint2D);
    {: This method draws the object on a canvas.

       A 2D object have to implement this method to draw itself
       appropriately.

       <I=VT> is the the mapping transform that can be obtained
       with the <See Property=TCADViewport@ViewportToScreenTransform> property.
       <I=Cnv> is the canvas on which draw the control points
       <See Class=TDecorativeCanvas@TDecorativeCanvas>, and
       <I=DrawMode> is a constant that correspond to the value
       of the <See Property=TCADViewport@DrawMode> property of
       the CADViewport that calls this method. It may be used to
       change the behaviour of the drawing method.
       <I=ClipRect> is the 2D pixel drawing area in 2D coordinates, you
       can use it in all of the drawing methods.
    }
    //TSY: "VT" instead of "const VT"
    procedure Draw(VT: TTransf2D; const Cnv:
      TDecorativeCanvas; const ClipRect2D: TRect2D; const
      DrawMode: Integer); virtual; abstract;
    {: This method returns <B=True> if the object is visible in the
       portion of the view plane given by the
       <See Property=TCADViewport@VisualRect> property of the viewport that
       called the method.

       This method is used to prune the object that must not be
       drawed to save time in the drawing process.

       <I=Clip> is the portion of the view plane that must be rendered, and
       <I=DrawMode> is a constant that correspond to the value
       of the <See Property=TCADViewport@DrawMode> property of
       the CADViewport that calls this method. It may be used to
       change the behaviour of the drawing method.

       By default this method returns <B=True> if the bounding box
       of the object is contained (also partially) in the <I=Clip>
       rectangle.
    }
    function IsVisible(const Clip: TRect2D; const DrawMode:
      Integer): Boolean; virtual;
    {: This method draws only the control points of the object.

       An 2D object may have a set of points that are called
       <I=control points> and that control the shape of the
       object. For example a circle may have two control points;
       the center of the circle and a point on the circle that
       specify the radious of it.

       <I=VT> is the the mapping transform that can be obtained
       with the <See Property=TCADViewport@ViewportToScreenTransform> property.
       <I=Cnv> is the canvas on which draw the control points
       <See Class=TDecorativeCanvas@TDecorativeCanvas>, and
       <I=Width> is the width in pixel of the control points (that are
       drawed as a square).
       <I=ClipRect> is the 2D pixel drawing area in 2D coordinates, you
       can use it in all of the drawing methods.

       This method uses the linked <See Class=TObject2DHandler> to
       draw the control points. If no handler is linked then no control point
       is drawed.
    }
    procedure DrawControlPoints(const VT: TTransf2D; const Cnv:
      TDecorativeCanvas; const ClipRect2D: TRect2D; const Width:
      Integer); dynamic;
    {: This returns the part of the object that is picked by a point.

       <I=Pt> is the picking point, <I=Aperture> is the picking aperture
       and <I=Distance> will contains the distance from <I=Pt> to
       the object.

       The method returns one of these values (ordered from the highest
       priority to the lowest priority):

       <LI=<I=PICK_NOOBJECT> if <I=Pt> is not on the object. Distance
       will became <See const=MaxCoord>.>
       <LI=<I=PICK_INBBOX> if <I=Pt> is inside the bounding box of the
       object. Distance will be equal to Aperture.>
       <LI=<I=PICK_ONOBJECT> if <I=Pt> is on the outline of the object
       with a distance less than Aperture. Distance will be that
       distance.>
       <LI=<I=PICK_INOBJECT> if <I=Pt> is inside the outline of the
       object. Distance will be set to Aperture.>
       <LI=A value greater than or equal to zero if <I=Pt> is on any of
       the control points, in this case the resulting value is that
       control point. Distance will be the distance form the control
       point.

       You must use this convention in your implementations of
       the method. (You can use the inherited method if some of these
       condition is the same as in the base class).
    }
    function OnMe(PT: TPoint2D; Aperture: TRealType; var
      Distance: TRealType): Integer; dynamic;
    {: This method set a new handler for the object to be used to handle it.
       Use this method for an handler that will be shared among different
       shapes.

       Call this method with <B=nil> to remove the current handler.
    }
    procedure SetSharedHandler(const Hndl: TObject2DHandler);
    {: This method set a new handler for the object to be used to handle it.
       A new handler will be created.

       Call this method with <B=nil> to remove the current handler.
    }
    procedure SetHandler(const Hndl: TObject2DHandlerClass);
    {: This property contains the bounding box of the object.

       The 2D object has a 2D bounding box, that is the smallest
       axis aligned rectangle that fully contains the object.
       This rectangle is always in the world coordinate system and
       so it doesn't depend on the model transform. The bounding box
       must be computed in the
       <See Property=TGraphicObject@_UpdateExtension> method that have
       to be redefined.
    }
    property Box: TRect2D read fBox;
    {: If this property is <B=True> then the bounding box is drawed
       in the <See Method=TObject2D@DrawControlPoints>.
    }
    property DrawBoundingBox: Boolean read fDrawBoundingBox write
      fDrawBoundingBox;
    {: This property contains the current handler object.

       See <See Class=TObject2DHandler@TObject2DHandler> for details.
    }
    //TSY:
    property HasControlPoints: Boolean read fHasControlPoints
      write
      fHasControlPoints;
    property Handler: TObject2DHandler read fHandler;
  end;

  {: This class defines a group of 2D objects, that is a close set
     of objects that share the same model transform.

     A container has a special behaviour for the picking operation.
     Since a container embrace a group of objects, the picking take
     effect at group level returning the ID of the selected object
     instead of its control point.

     A container can be used to group objects that must be moved or
     transformed as a whole. On the other hand, if you want to reuse
     a set of objects in different place on the drawing use the
     <See Class=TSourceBlock2D> class.
  }
  TContainer2D = class(TObject2D)
  private
    { List of objects in the container. }
    fObjects: TGraphicObjList;
  protected
    procedure _UpdateExtension; override;
  public
    {: This is the constructor for the class.

       It creates an instance of the container. This constructor needs:

       <LI=the ID of the container. This identifier univocally identifies
       the object in the CAD. See also <See Method=TDrawing@AddObject>.>
       <LI=the array of objects that must be added to the set. After
       you have created the container it is possible to add and
       remove objects throught the <See Property=TContainer2D@Objects> property.>

       If you want to create a void container you have to supply an
       array with only one item set to <B=nil> (ie <B=[nil]>).

       The objects in the container are owner by the container
       itself and will be freed when the container is deleted. So it
       isn't possible to share objects between containers.
    }
    constructor Create(ID: Integer); override;
    constructor CreateSpec(ID: Integer; const Objs: array of
      TObject2D);
    destructor Destroy; override;
    constructor CreateFromStream(const Stream: TStream; const
      Version: TCADVersion); override;
    procedure SaveToStream(const Stream: TStream); override;
    procedure Assign(const Obj: TGraphicObject); override;
    {: This method updates the references of the source blocks
       that are used in the container.

       This method is called automatically at the end of the loading
       process from a stream. Indeed when you save a container it
       may contains <See Class=TBlock2D> instances that references
       to <See Class=TSourceBlock2D> instances. When the application
       is closed these references are no longer valid, so the blocks
       must be relinked to the corrent source blocks.

       The method needs the iterator of source blocks list in order
       to relink the blocks. This iterator can be obtained from
       <See Property=TDrawing@SourceBlocksIterator>.

       The method call the <See Method=TGraphicObject@UpdateExtension>.
    }
    procedure UpdateSourceReferences(const BlockList:
      TGraphicObjIterator);
    procedure Draw(VT: TTransf2D; const Cnv:
      TDecorativeCanvas; const ClipRect2D: TRect2D; const
      DrawMode: Integer); override;
    procedure DrawControlPoints(const VT: TTransf2D; const Cnv:
      TDecorativeCanvas; const ClipRect2D: TRect2D; const Width:
      Integer); override;
    function OnMe(PT: TPoint2D; Aperture: TRealType; var
      Distance: TRealType): Integer; override;
    {: This property contains the list that contians the object in the container.

       The objects in the container are owned by the container itself. Use
       this property to manage these objects.
    }
    property Objects: TGraphicObjList read fObjects;
  end;

  {: This class defines a group of 2D objects that can be placed
     in different points of the drawing. This is the efficent
     way to compose a drawing from repeated part of it.

     This class defines a template that can be instantiated,
     and any instance has its own model transformation but share
     the same objects of the template. The instances of this
     template are obtained with <See Class=TBlock2D> class.

     This kind of object must be added to the CAD using the
     <See Method=TDrawing2D@AddSourceBlock> and
     <See Class=TDrawing2D@BlockObjects> methods.
  }
  TSourceBlock2D = class(TContainer2D)
  private
    fNReference: Word; { Number of reference }
    fName: TSourceBlockName;
    fLibraryBlock: Boolean;
  public
    {: This is the constructor of the class.

       A source block is referenced either by use of its ID or by use
       of its name.
       This constructor needs:

       <LI=the ID of the source block. This identifier univocally
       identify the source block in the CAD.>
       <LI=the name of the source block. The name is of type
       <See Type=TSourceBlockName>.>
       <LI=the array of objects that must be added to the source
       block. After you have created the source blocks it is possible
       to add and remove objects afterward throught the
       <See Property=TContainer2D@Objects> property.>

       The objects in the source block are owner by the source block
       itself and they will be freed when the source block is deleted.
       So it isn't possible to share objects between source block, but
       it is possible to share these objects using the <See Class=TBlock2D>
       class.
    }
    constructor Create(ID: Integer); override;
    constructor CreateSpec(ID: Integer; const Name:
      TSourceBlockName; const Objs: array of TObject2D);
    constructor CreateFromStream(const Stream: TStream; const
      Version: TCADVersion); override;
    destructor Destroy; override;
    procedure SaveToStream(const Stream: TStream); override;
    procedure Assign(const Obj: TGraphicObject); override;
    {: This property contains the name of the source block.

       See also <See Type=TSourceBlockName>.
    }
    property Name: TSourceBlockName read fName write fName;
    {: This property contains the number of instances of the
       source block, that is the number of <See Class=TBlock2D>
       objects that are linked to it.

       When a new block is created to reference a source block,
       this property is incremented by one. When the block is
       deleted this numeber is decremented by one.

       Only if this value is zero the source block can be deleted.
    }
    property NumOfReferences: Word read fNReference;
    {: This property tells if the source block is a library source
       block.

       A library source block is a source block that is shared among
       differert drawings, made up a library of symbols.

       When this property is <B=True>, the source block will not be
       saved in a drawing file, but can be stored in a library file
       by using the methods <See Method=TDrawing@SaveLibrary>
       and <See Method=TDrawing@LoadLibrary>.

       If this property is <B=False>, the source block will be
       saved in the drawing file.

       If <See Property=TGraphicObject@ToBeSaved> is <B=False> the
       source block will not be saved anyway.
    }
    property IsLibraryBlock: Boolean read fLibraryBlock write
      fLibraryBlock;
  end;

  {: This class defines an instance of a <See Class=TSourceBlock2D>.

     A block is an istance of a source block, namely a copy of the
     source block that has its own model transform but share the
     same objects that define the source block.

     A block is an indipendent entity when it is concerned with
     the model transform, but it depends on the source block for
     its shape.
  }
  TBlock2D = class(TObject2D)
  private
    { Reference to the source block. }
    fSourceBlock: TSourceBlock2D;
    fSourceName: TSourceBlockName;
    { Origin of the block. }
    fOriginPoint: TPoint2D;

    procedure SetSourceBlock(const Source: TSourceBlock2D);
    procedure SetOriginPoint(PT: TPoint2D);
  protected
    procedure _UpdateExtension; override;
  public
    {: This is the constructor of the class.

       <I=Source> is the source block that is used to define
       the instance.
    }
    constructor Create(ID: Integer); override;
    constructor CreateSpec(ID: Integer; const Source:
      TSourceBlock2D);
    destructor Destroy; override;
    constructor CreateFromStream(const Stream: TStream; const
      Version: TCADVersion); override;
    procedure SaveToStream(const Stream: TStream); override;
    procedure Assign(const Obj: TGraphicObject); override;
    {: This method updates the references of the block.

       This method is called automatically at the end of the loading
       process of the block from a stream. Indeed when you save a
       block the reference to the source block is no longer valid,
       so the block must be relinked to the correct source blocks
       instance.

       The method needs the iterator of the source blocks of a CAD in
       order to relink the block's source block. This iterator can be
       obtained by <See Property=TDrawing@SourceBlocksIterator>
    }
    procedure UpdateReference(const BlockList:
      TGraphicObjIterator);
    procedure DrawControlPoints(const VT: TTransf2D; const Cnv:
      TDecorativeCanvas; const ClipRect2D: TRect2D; const Width:
      Integer); override;
    procedure Draw(VT: TTransf2D; const Cnv:
      TDecorativeCanvas; const ClipRect2D: TRect2D; const
      DrawMode: Integer); override;
    function OnMe(PT: TPoint2D; Aperture: TRealType; var
      Distance: TRealType): Integer; override;
    {: This property contains the base position of the block.

       The origin point is the position of the (0, 0) inside of
       the source block that is referenced by the block.

       The origin point is only a visual reference and doesn't
       alter the model transform (but it is altered from it).
    }
    property OriginPoint: TPoint2D read fOriginPoint write
      SetOriginPoint;
    {: This property contains the reference to the source block used by the block.

       See also <See Class=TSourceBlock2D>.
    }
    property SourceBlock: TSourceBlock2D read fSourceBlock write
      SetSourceBlock;
    {: This property contains the name of the source block
       referenced by the block.

       It is used to save the source block reference into a stream,
       and it is used to relink the source block reference when the
       block is loaded back.
    }
    property SourceName: TSourceBlockName read fSourceName;
  end;

  //TSY:
  TCheckSum = MD5Digest;

  //TSY:
  TDrawHistory = class(TObjectList)
  private
    fDrawing: TDrawing2D;
    fPosition: Integer;
    fCheckSum, fSavedCheckSum: TCheckSum;
    fOptCheckSum, fSavedOptCheckSum: TCheckSum;
    function GetCanUndo: Boolean;
    function GetCanRedo: Boolean;
    function GetIsChanged: Boolean;
  public
    constructor Create(ADrawing: TDrawing2D);
    procedure Truncate(Index: Integer);
    procedure Save;
    procedure Undo;
    procedure Redo;
    procedure Clear; override;
    procedure SaveCheckSum;
    procedure SetPropertiesChanged;
    property CanUndo: Boolean read GetCanUndo;
    property CanRedo: Boolean read GetCanRedo;
    property IsChanged: Boolean read GetIsChanged;
  end;

  TOnPasteMetafileFromClipboard = procedure(Drawing: TDrawing2D) of object;

  {: This class defines a specialization of a <See Class=TDrawing>
     control (see it for details).

     This Drawing handles 2D objects and source blocks.
     This component must be used when you need to store 2D drawing.
  }
  TDrawing2D = class(TDrawing)
  private
    //TSY:
    fArrowsSize: TRealType;
    fStarsSize: TRealType;
    fFileName: string;
    function GetExtension: TRect2D;
  public
    TeXFormat: TeXFormatKind;
    PdfTeXFormat: PdfTeXFormatKind;
    DefaultFontHeight: TRealType;
    Caption: string;
    FigLabel: string;
    Comment: string;
    {PicHeight: Integer;
    PicWidth: Integer;}
    PicScale: TRealType;
    PicUnitLength: TRealType;
    HatchingStep: TRealType;
    HatchingLineWidth: TRealType;
    DottedSize: TRealType;
    DashSize: TRealType;
    FontName: string;
    TeXMinLine: TRealType;
    TeXCenterFigure: Boolean;
    TeXFigure: TeXFigureEnvKind;
    TeXFigurePlacement: string;
    TeXFigurePrologue: string;
    TeXFigureEpilogue: string;
    TeXPicPrologue: string;
    TeXPicEpilogue: string;
    LineWidthBase: TRealType;
    MiterLimit: TRealType;
    //FactorMM: TRealType; // for line width
    Border: TRealType;
    PicMagnif: TRealType;
    MetaPostTeXText: Boolean;
    IncludePath: string;
    DefaultSymbolSize: TRealType;
    History: TDrawHistory;
    OptionsList: TOptionsList;
    OnPasteMetafileFromClipboard: TOnPasteMetafileFromClipboard;
    procedure LoadObjectsFromStream(const Stream: TStream; const
      Version: TCADVersion); override;
    //TSY:
    procedure SaveObjectsToStream0(const Stream: TStream;
      const Iter: TGraphicObjIterator);
    procedure SaveObjectsToStream(const Stream: TStream);
      override;
    procedure SaveSelectionToStream(const Stream: TStream);
    procedure CopySelectionToClipboard;
    procedure PasteFromClipboard;
    procedure FillOptionsList;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetDefaults; virtual;
    procedure Clear; virtual;
    {: This method loads the blocks definitions (see <See Class=TSourceBlock2D>) from a drawing.
       This is an abstract method that must be implemented in a concrete control.

       <I=Stream> is the stream that contains the blocks (and it must be
       positioned on the first block present). The stream must be
       created with the current version of the library.
       The blocks are created by reading the shape class registration index
       and creating the correct shape instance with the state present in the
       stream. Then this instance is saved in the list of objects of the
       source block.

       When a source block is loaded the objects that are contained in the
       source block are checked for recursive nesting of blocks. It is
       allowed to have a source block that use in its definition another
       source block, BUT this source block must be loaded before the
       source block that use it (this is automatically checked when you
       define a block). When the source block is loaded its
       <See Method=TContainer2D@UpdateSourceReferences> is called to
       update the references.

       If there is a block that references to a not defined source block
       a message will be showed and the source block will not be loaded.

       See also <See=oObject's Persistance@PERSISTANCE>.
    }
    procedure LoadBlocksFromStream(const Stream: TStream; const
      Version: TCADVersion); override;
    {: This method saves the blocks definitions (see <See Class=TSourceBlock2D>) to a drawing.
       This is an abstract method that must be implemented in a concrete control.

       <I=Stream> is the stream into which save the source blocks,
       <I=AsLibrary> tells if list of source blocks must be saved as
       a library. A Library will contains only the source blocks that
       have the <See Property=TGraphicObject@ToBeSaved> property set to
       <B=True> and the <See Property=TSourceBlock2D@IsLibraryBlock>
       property set to <B=True>. This is useful to create library of
       blocks definition to be shared beetwen drawing.

       See also <See=Object's Persistance@PERSISTANCE>.
    }
    procedure SaveBlocksToStream(const Stream: TStream; const
      AsLibrary: Boolean); override;
    {: This method adds a new source block.

       <I=ID> is the identifier number of the source block and Obj is the
       source block object. The library doesn't check for uniqueness of
       source block's ID. The given ID substitute the ID of Obj. A source
       block can also be referenced by its name and again the library
       doesn't check for its uniqueness.

       A source block is a collection of objects that are drawed at a whole
       on the viewport. A source block must be istantiated before the
       drawing occourse by define a block that references it. The instance
       has a position so you can share the same collection of objects and
       draw it in different places on the same drawing. This allows the
       efficent use of memory. If a source block is modified, all the
       instances are modified accordingly.

       The method returns the added block.

       See also <See Class=TSourceBlock2D> and
       <See Class=TBlock2D>.
    }
    function AddSourceBlock(const Obj: TSourceBlock2D):
      TSourceBlock2D;
    {: This method deletes the source block with the specified Name.

      <I=ID> is the identification number of the source block. If no such
      block is found a <See Class=ECADListObjNotFound> exception will be raised.

      If the source block to be delete is in use (that is it is referenced
      by some <See Class=TBlock2D> object) a
      <See Class=ECADSourceBlockIsReferenced> exception will be raised and the
      operation aborted. In this case you must delete the objects that
      reference the source block before retry.
    }
    procedure DeleteSourceBlock(const SrcName:
      TSourceBlockName);
    function GetSourceBlock(const ID: Integer): TSourceBlock2D;
    function FindSourceBlock(const SrcName: TSourceBlockName):
      TSourceBlock2D;
    {: This method creates a source block (and add it to the CAD) by
       grouping a list of objects.

       <I=ScrName> will be the name of the source block; <I=Objs> is
       an iterator on the list that contains the objects to be added.
       That list must have the <See Property=TGraphicObjList@FreeOnClear>
       property set to <B=False>.
    }
    function BlockObjects(const SrcName: TSourceBlockName; const
      Objs: TGraphicObjIterator): TSourceBlock2D;
    procedure DeleteLibrarySourceBlocks; override;
    procedure DeleteSavedSourceBlocks; override;
    function AddObject(const ID: Integer; const Obj: TObject2D):
      TObject2D;
    function InsertObject(const ID, IDInsertPoint: Integer; const
      Obj: TObject2D): TObject2D;
    {: This method adds a new block (instance of a source block) into
       the CAD.

       <I=ID> will be the identifier of the new block,
       and <I=SrcName> is the name of the source block used to
       define the block.

       If the source block isn't in the CAD an exception will be
       raised. The method returns the reference of the added block.
    }
    function AddBlock(const ID: Integer; const SrcName:
      TSourceBlockName): TObject2D;
    function GetObject(const ID: Integer): TObject2D;
    {: This method transforms a set of object or all the objects
       present in the CAD.

       The method applies the <I=T> transform matrix to the objects
       with the <I=ID> that are present in <I=ListOfObj>. This
       parameter is an array that may contains:

       <LI=only one element equal to -1. In this case <I=T> will be
       applied to all the objects present in the CAD.
       <LI=a list of integers greater or equal to zero. In this case
       <I=T> will be applied to the objects with the specified
       <I=IDs>. The array must not have duplicated IDs.

       If some ID in the array doesn't refer to an object in the CAD
       an <See Class=ECADListObjNotFound> exception will be raised
       and the operation stopped.
    }
    procedure TransformObjects(const ListOfObj: array of
      Integer; const T: TTransf2D);
    procedure ScaleAll(const P: TPoint2D; ScaleX, ScaleY:
      TRealType);
    function ScaleStandard(ScaleStandardMaxWidth,
      ScaleStandardMaxHeight: TRealType): TTransf2D;
    procedure ScalePhysical(const S: TRealType);
    procedure RedrawObject(const Obj: TObject2D);
//TSY:
    function PickObject(const PT: TPoint2D;
      const Aperture: TRealType;
      const VisualRect: TRect2D; const DrawMode: Integer;
      const FirstFound: Boolean; var NPoint: Integer): TObject2D;
    procedure MakeGrayscale;
    {: This property contains the extension of the drawing.

       The drawing extension is the smallest axis aligned
       rectangle that bounds all the objects in the CAD.
       When you refer to the property the extension rectangle is
       computed and this may require a bit of time for a complex draw.

       If you want to use this value more than once in a series of
       computations, it is better to store it in a local variable
       instead of use this property in all the computations.
    }
    property DrawingExtension: TRect2D read GetExtension;
    property ArrowsSize: TRealType read fArrowsSize write
      fArrowsSize;
    property StarsSize: TRealType read fStarsSize write
      fStarsSize;
    property FileName: string read fFileName write fFileName;
  end;

  {: This component derives from <See Class=TCADViewport> and
     specialize it to handle 2D objects.

     In this case the world is the view plane of TCADViewport
     and so the projection transform is simply an indentity tranform matrix.

     See <See Class=TCADViewport> for details.
  }
  TCADViewport2D = class(TCADViewport)
  private
    fPickFilter: TObject2DClass;
      { consider only the objects with this type during the picking. }
    fDrawing2D: TDrawing2D;
    { Event handlers }
    fOnMouseDown2D, fOnMouseUp2D: TMouseEvent2D;
    fOnMouseMove2D: TMouseMoveEvent2D;
    FOnMouseWheel: TMouseWheelEvent;
    fImageList: TImageList;
    fBrushBitmap: TBitmap;

    procedure SetDrawing2D(CAD2D: TDrawing2D);
    procedure CMMouseWheel(var Message: TCMMouseWheel); message
      CM_MOUSEWHEEL;
  protected
    procedure SetDrawing(Cad: TDrawing); override;
    procedure DrawObject(const Obj: TGraphicObject; const Cnv:
      TDecorativeCanvas; const ClipRect2D: TRect2D); override;
//TSY:
    procedure DrawObjectControlPoints(const Obj: TGraphicObject;
      const Cnv: TDecorativeCanvas; const ClipRect2D: TRect2D);
      override;
    procedure DrawObjectWithRubber(const Obj: TGraphicObject;
      const Cnv: TDecorativeCanvas; const ClipRect2D: TRect2D);
      override;
    function BuildViewportTransform(var ViewWin: TRect2D; const
      ScreenWin: TRect; const AspectRatio: TRealType):
      TTransf2D;
      override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);
      override;
    procedure MouseDown(Button: TMouseButton; Shift:
      TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta:
      Integer; MousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {: This method draws a 2D object on the viewport.

       <I=Obj> is that object to be drawed. If <I=CtrlPts> is <B=True>
       the control points of the object will also be drawed.

       The object is drawed by calling its <See Method=TObject2D@Draw>
       method if it is visible (that is it is contained in the
       <See Property=TCADViewport@VisualRect>)).
    }
    procedure DrawObject2D(const Obj: TObject2D; const CtrlPts:
      Boolean);
    {: This method draws a 2D object on the viewport.

       <I=Obj> is that object to be drawed. If <I=CtrlPts> is <B=True>
       the control points of the object will also be drawed.

       The object is drawed by calling its <See Method=TObject2D@Draw>
       method if it is visible (that is it is contained in the
       <See Property=TCADViewport@VisualRect>)).

       This method draws the object only on the canvas of the control
       and not in the off-screen buffer. So if you call the
       <See Method=TCADViewport@Refresh> method the effect of this
       method are removed without the need to a complete Repaint.
    }
    procedure DrawObject2DWithRubber(const Obj: TObject2D; const
      CtrlPts: Boolean);
    procedure CopyRectToCanvas(CADRect: TRect2D; const
      CanvasRect: TRect; const Cnv: TCanvas; const Mode:
      TCanvasCopyMode); override;
    function GetCopyRectViewportToScreen(CADRect: TRect2D; const
      CanvasRect: TRect; const Mode: TCanvasCopyMode):
      TTransf2D;
      override;
    procedure ZoomToExtension; override;
    {: This method fill in a list with the objects that are contained
       in a rectangular region of the view plane.

       <I=ResultLst> is the list that will contain the objects found;
       <I=Frm> is a rectangle in view plane coordinates.
       <I=Mode> may be one of the following values:

       <LI=if it is <I=gmAllInside> then only the objects that
         are fully contained in the rectangle are inserted into the list.>
       <LI=if it is <I=gmCrossFrame> then the objects that are
         fully or partially contained in the rectangle are inserted
         into the list.>

       If <I=RemoveFromCAD> is <B=True> then the objects added to
       the list are also removed from the CAD.

       This method is useful for create a pick-in-region function,
       or to create a source block with the objects in a region
       by removing the objects found from the CAD.
    }
    procedure GroupObjects(const ResultLst: TGraphicObjList;
      Frm: TRect2D; const Mode: TGroupMode; const RemoveFromCAD:
      Boolean);
    {: This method returns an object that has the point <I=Pt> on it.

       The method traverses the list of objects to find an object
       that is at a distance from <I=Pt> less than <I=Aperture>. If
       that object is found then it will be returned by the method,
       otherwise the method will returns <B=nil>.

       <I=Pt> is the point of the picking; <I=Aperture> is the width
       of the picking region in <B=pixel>.

       <I=NPoint> will contains (if an object will be picked) one of
       the following values:

       <LI=<I=PICK_NOOBJECT> if no object is found at <I=Pt>.>
       <LI=<I=PICK_INBBOX> if an object is found that has <I=Pt> in its bounding box.>
       <LI=<I=PICK_ONOBJECT> if an object is found that has <I=Pt> on its outline.>
       <LI=<I=PICK_INOBJECT> if an object is found that has <I=Pt> in its interior.>
       <LI=a value equal or greater than zero if an object is found
         that has <I=Pt> on one of its control points.>

       The above value are ordered from the lowest priority to the
       greater priority. If more than one of the above condition is
       matched the value with the greater priority is returned.

       If there are more than one object at the point <I=Pt> the
       following rules are applied:

       <LI=The object with the greater priority value is returned>
       <LI=The last object added to the CAD is returned.>

       The display list is traversed until the last object is
       encountered and this may require a bit of time in the
       case of a complex object. If you are satisfied to found
       the first encountered object that is picked by the point
       <I=Pt> you may want to set <I=FirstFound> to <B=True>.

       <B=Note>: The method use the <See Method=TObject2D@OnMe> method
       to check for the picking. If you need a special picking function
       you may want to call that method.
    }
    function PickObject(PT: TPoint2D; Aperture: Word;
      FirstFound: Boolean; var NPoint: Integer): TObject2D;
    {: This method fills a list with the object that are at a distance
       from <I=Pt> less than <I=Aperture>.

       The method perform the same operation of <See Method=TCADViewport2D@PickObject>
       method but the objects that are picked by the point <I=Pt> are all
       added to the list <I=PickedObjects> in the same order as they
       are encountered.
    }
    function PickListOfObjects(const PickedObjects: TList; PT:
      TPoint2D; Aperture: Word): Integer;
      //TSY: similar to PickObject, but takes into account selection
    function PickObjectWithSelection(const PT: TPoint2D;
      const Aperture: Word;
      const FirstFound: Boolean; var NPoint: Integer): TObject2D;
    {: This method returns the point <I=WPt> in world coordinate system
       transformed by the inverse of the object model trasform of <I=Obj>.

       This method simply obtain the point <I=WPt> referenced in
       the object coordinate system of <I=Obj>.
    }
    function WorldToObject(const Obj: TObject2D; WPt: TPoint2D):
      TPoint2D;
    {: This method returns the point <I=OPt> in object coordinate system
       transformed by the object model trasform of <I=Obj>.

       This method simply obtain the point <I=OPt> referenced in
       the world coordinate system.
    }
    function ObjectToWorld(const Obj: TObject2D; Opt: TPoint2D):
      TPoint2D;
    {: This property may contains a class variable that is used to limit
       the picking to only the objects of that class.

       This property is used in <See Method=TCADViewport2D@PickObject>,
       <See Method=TCADViewport2D@PickListOfObjects> and
       <See Method=TCADViewport2D@GroupObjects>.
    }
    property PickFilter: TObject2DClass read fPickFilter write
      fPickFilter;
  published
    property ImageList: TImageList read fImageList write
      fImageList;
    {: This property contains the <See Class=TDrawing2D> control that
       acts as the source for the drawing to be painted in the
       viewport.

       The Drawing2D contains the display list of the drawing that will
       be rendered in the canvas of the viewport control.

       You must assign it before using the viewport.
    }
    property Drawing2D: TDrawing2D read fDrawing2D write
      SetDrawing2D;
    {: EVENTS}
    {: This property may contain an event-handler that will be
       called when the mouse in moved on the control.

       See <See Type=TMouseMoveEvent2D> for details on the event
       handler.
    }
    property OnMouseMove2D: TMouseMoveEvent2D read fOnMouseMove2D
      write fOnMouseMove2D;
    {: This property may contain an event-handler that will be
       called when the user presses a mouse button with the mouse pointer
       over the viewport.

       See <See Type=TMouseEvent2D> for details on the event
       handler.
    }
    property OnMouseDown2D: TMouseEvent2D read fOnMouseDown2D
      write fOnMouseDown2D;
    {: This property may contain an event-handler that will be
       called when the user releases a mouse button with the mouse pointer
       over the viewport.

       See <See Type=TMouseEvent2D> for details on the event
       handler.
    }
    property OnMouseUp2D: TMouseEvent2D read fOnMouseUp2D write
      fOnMouseUp2D;
    property OnMouseWheel: TMouseWheelEvent read FOnMouseWheel
      write FOnMouseWheel;
  end;

{ -----===== Starting Cs4CADPrgClass.pas =====----- }
  {: This type defines the events that a <See Class=TCADPrg> manages.

     These events are to be considered in the implementation of the
     <See Method=TCADState@OnEvent> method. See it for details.

     These are the events and their parameters:

     <LI=<I=ceMouseMove>, <I=ceMouseDown>, <I=ceMouseUp> and <I=ceMouseDblClick>
       are mouse events. The various points properties (<I=Current*Point>)
       are the coordinates of the mouse position.>
     <LI=<I=ceKeyDown> and <I=ceKeyUp> are the keyboard events.>
     <LI=<I=cePaint> is the event fired when the viewport is repainted.>
     <LI=<I=ceUserDefined> is a user defined event. Its kind is in the
       <I=Key> parameters of the <See Method=TCADState@OnEvent> method.>
  }
  TCADPrgEvent = (ceMouseMove,
    ceMouseDown,
    ceMouseUp,
    ceMouseDblClick,
    ceKeyDown,
    ceKeyUp,
    cePaint,
    ceUserDefined);

  TCADPrg = class;

  {: This type define the class type used to specify a <See Class=TCADState> class.
  }
  TCADStateClass = class of TCADState;

  {: This class defines the common interface for the parameter
     used in a task.

     A state of a task can receive an instance of this type
     as parameter for its operation.
     The <B=task> can then accomplish its operation by using the
     information in the parameter. A task may dont need a parameter.

     All parameter types have a field that can store a state
     class reference: <I=AfterState>. This state will be activated
     when the task is ended, passing it the current parameter.
     If you define a new state you have to implement this behaviour.

     For example a common code to end an operation in the
     OnEvent method is the follow:

     <CODE=if Assigned(Param.AfterState) then<BR>
           <TAB> NextState := Param.AfterState<BR>
           else <BR>
           <TAB> NextState := CADPrg.DefaultSatate; <BR>
           Result := True;
     >
  }
  TCADPrgParam = class(TObject)
  private
    fAfterState: TCADStateClass;
    fUserObject: TObject;
  public
    {: This is the constructor of the parameter.

       <I=AfterS> is the class reference of the state to be
       started at the end of the current one.

       All parameter types have a field that can store a state
       class reference: <I=AfterState>. This state will be activated
       when the <B=task> is ended, passing it the current parameter.
       If you define a new state you have to implement this behaviour.
    }
    constructor Create(AfterS: TCADStateClass);
    {: This property contains a class reference of the state to be
       started at the end of the current one.

       All parameter types have a field that can store a state
       class reference: <I=AfterState>. This state will be activated
       when the <B=task> is ended, passing it the current parameter.
       If you define a new state you have to implement this behaviour.
    }
    property AfterState: TCADStateClass read fAfterState write
      fAfterState;
    {: This property may contain a user object reference interpreted
       by the current task.
    }
    property UserObject: TObject read fUserObject write
      fUserObject;
  end;

  TCS4MouseButton = (cmbNone, cmbLeft, cmbRight, cmbMiddle);
  {: This class defines a state of a interaction task.

     <See Class=TCADPrg> is based on a <I=FSM model> (finite state
     machine) in which an interaction task is is a set of states,
     each of them execute some part of the whole task.
     The interaction task (from now on simply a task) evolves through
     the states in respons to <I=events>. An <I=event> is some action
     on the CADPrg or the linked Viewport performed by the user or
     by the control itself.
     A task is an <I=active state>, that is the state with receives
     the events (through the implementation of the
     <See Method=TCADState@OnEvent>).
     The active state decides what operation performs in response to
     the event. See <See Method=TCADState@OnEvent> for details.

     The events are (see also TCADPrgEvent) <I=mouse events, keyboard
     events, expose events and user events>.

     The user must derives its states from this class to implement
     an interaction task. A state may be reused in more that one
     interaction task.

     An interaction task is started by using the
     <See Method=TCADPrg@StartOperation>,
     <See Method=TCADPrg@SuspendOperation> and passing it the first
     state of it.

     To define a state you may want to implement the following
     methods:

     <LI=<See Method=TCADState@Create> in which you place the
       initialization code for the state>
     <LI=<See Method=TCADState@OnEvent> in which you place the
       code to handle the events>
     <LI=<See Method=TCADState@OnStop> in which you plane the
       finalization code for the interaction task (this method
       is called when an interaction task is stopped, no when
       the state instace is destroyed.>

     <B=Note>: The instance of a state is created by the <See Class=TCADPrg>
      control.
  }
  TCADState = class(TObject)
  private
    fCAD: TCADPrg;
      { Used to store the CAD that is using the state. }
    fParam: TCADPrgParam;
      { A state as a parameter when it is created. }
    fCanBeSuspended: Boolean;
      { default True. If false the state cannot be suspended. }
    fDescription: string;
      { Contains a description of the state. }

    procedure SetDescription(D: string);
  protected
    property CADPrg: TCADPrg read fCAD;
  public
    {: This is the contructor of the state in which you may place
       the code for the initialization of the state.

       <I=CADPrg> is the <See Class=TCADPrg> control that has called
       the constructor; <I=StateParam> is an optional parameter
       passed to the state (it may be <B=nil>), see <See Class=TCADPrgParam>.

       <I=NextState> may contains a class reference to a state class
       that will be the next state when the constructor terminate.
       Set this parameter if you want a state that only change the
       parameter and leave the actual task implementation to other
       states.
    }
    constructor Create(const CADPrg: TCADPrg; const StateParam:
      TCADPrgParam; var NextState: TCADStateClass); virtual;
    {: This method is called by the CADPrg when an event is pending for
       the state. See <See Class=TCADState> for details.

       <I=Event> is the event to be handled; <I=MouseButton> is the
       mouse button that caused the event (if applicable);
       <I=Shift> is the special keys configurations when the event
       was created (if applicable); <I=Key> is the key that is currently
       pressed by the user.

       <I=NextState> may contain a class reference value to a state class
       that will became the active state at the moment the method returns.
       If you put a value into this parameter you also need to return
       <B=True> from the method. Otherwise you must return <B=False>.

       Use this method to handle the events and perform operations
       or change the active state.
    }
    function OnEvent(Event: TCADPrgEvent; MouseButton:
      TCS4MouseButton;
      Shift: TShiftState; Key: Word;
      var NextState: TCADStateClass): Boolean; dynamic;
    {: This method is called when the current interactive task is
       stopped by calling the <See Method=TCADPrg@StopOperation> method.

       Use it to free any resource in the interactive task and
       in the parameter of the state.
    }
    procedure OnStop; dynamic;
    {: This method is called when the current interactive task is
       suspended by calling the <See Method=TCADPrg@SuspendOperation>
       method.

       <I=State> is the suspended state and <I=SusParam> is the
       parameter of the suspended state.
    }
    procedure OnResume(const State: TClass; const SusParam:
      TCADPrgParam); dynamic;
    //TSY:
    procedure OnSuspend(const State: TClass; const SusParam:
      TCADPrgParam); dynamic;
    {: This property contains an optional description of the
       interaction task.

       It is useful to inform the user to which operations are
       needed to complete the interaction task. When this
       property is changed an <See Property=TCADPrg@OnDescriptionChanged>
       event is fired.
    }
    function SelectedObjs: TGraphicObjList;
    function SelectionFilter: TObject2DClass;
    property Description: string read fDescription write
      SetDescription;
    {: If this property is <B=True> then the iteraction task to which
       the state belonging can be interrupted with the
       <See Method=TCADPrg@StopOperation>.
    }
    property CanBeSuspended: Boolean read fCanBeSuspended write
      fCanBeSuspended;
    {: This property contains the parameter of the state. It is
       set by the TCADPrg when the state is activated but you
       may (and sometimes is very useful) be changed through this
       property.
    }
    property Param: TCADPrgParam read fParam write fParam;
  end;

  {: This class implements a state that does nothing.

     It is useful for a default state.
  }
  TCADIdleState = class(TCADState)
  public
    constructor Create(const CADPrg: TCADPrg; const StateParam:
      TCADPrgParam; var NextState: TCADStateClass); override;
  end;

  {: This type defines an event-handler for the event fired when
     the active state is changed.

     <I=Sender> is the TCADPrg that create the instance of the state;
     <I=Sender> is the changed state (if the event is a
     <See Property=TCADPrg@OnEnterState> this is the entering state,
     if the event is a <See Property=TCADPrg@OnExitState> this is
     the leaving state).
  }
  TCADPrgOnChangeState = procedure(Sender: TObject; const State:
    TCADState) of object;
  {: This type defines an event-handler for the event fired when
     the current interaction task of a TCADPrg is aborted, ended
     or started.

     <I=Sender> is the TCADPrg instance that has started the
     interaction task. <I=Operation> is the initial state
     of the interaction task and <I=Param> is the parameter of
     the interaction task.
  }
  TCADPrgOnOperation = procedure(Sender: TObject; const
    Operation: TCADStateClass; const Param: TCADPrgParam) of
    object;

  {: This class defines the control used by the library to handle
     interaction tasks. An interaction task is an interactive
     visual sequence of operation on a Viewport.

     The control implement a FSM (Finite state machine) model
     that receives events from the user and the Viewport.

     See also <See Class=TCADState> class for details.
  }
  TCADPrg = class(TComponent)
  private
    fLinkedViewport: TCADViewport;
    fIsBusy, fIsSuspended: Boolean;
    fUseSnap, fUseOrto: Boolean;
    fSnapX, fSnapY: TRealType;
    fRepaintRect: TRect2D;
    fCursorColor: TColor;
    fMustRepaint, fRefreshAfterOp: Boolean;
    fIgnoreEvents: Boolean;
    fCurrentKey: Word;
    fDefaultState: TCADStateClass;
    fCurrentState, fSuspendedState: TCADState;
    fCurrentOperation, fSuspendedOperation: TCADStateClass;
    fOnEntState, fOnExState: TCADPrgOnChangeState;
    fOnEndOperation, fOnStart, fOnStop: TCADPrgOnOperation;
    fOldOnPaint, fOnIdle: TNotifyEvent;
    fOnDescriptionChanged: TNotifyEvent;
    fShowCursorCross: Boolean;
    fNewWndProc, fOldWndProc: Pointer;

    procedure SetShowCursorCross(B: Boolean);
    procedure SetCursorColor(C: TColor);
    procedure SetDefaultState(DefState: TCADStateClass);
    procedure SetLinkedViewport(V: TCADViewport);
    procedure GoToDefaultState(const LastState: TClass; const
      LastParam: TCADPrgParam);
  protected
    procedure SubclassedWinProc(var Msg: TMessage); virtual;
    procedure Notification(AComponent: TComponent; Operation:
      TOperation); override;
    {: This property must returns the current viewport point at which
       the mouse is positioned.

       The control doesn't send the mouse coordinates with the events,
       but the user must use the <I=Current*Point> properties defined
       for <See Class=TCADPrg2D> and <See Class=TCADPrg3D>.
    }
    function GetVPPoint: TPoint2D; virtual; abstract;
    {: This property is called whenever the mouse is moved and the
       current viewport point stored in the control must be updated.

       <I=Pt> is the 2D mouse position in the view plane coordinate system.

       The control doesn't send the mouse coordinates with the events,
       but the user must use the <I=Current*Point> properties defined
       for <See Class=TCADPrg2D> and <See Class=TCADPrg3D>.
    }
    procedure SetVPPoint(const PT: TPoint2D); virtual; abstract;
    {: Use this method to draw the cursor at the mouse position.

       You have to implement this property also if you don't want
       a cursor (in this case simple do nothing).
    }
    procedure DrawCursorCross; virtual; abstract;
    {: Use this method to hide the cursor at the mouse position.

       You have to implement this property also if you don't want
       a cursor (in this case simple do nothing).
    }
    procedure HideCursorCross; virtual; abstract;
    {: This method is called whenever a point event is received.

       You don't need to use it.
    }
    procedure ViewOnPaint(Sender: TObject); dynamic;
    {: This method is called whenever a key event is received.

       You don't need to use it.
    }
    function ViewOnKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState): Boolean; dynamic;
    {: This method is called whenever a key event is received.

       You don't need to use it.
    }
    function ViewOnKeyUp(Sender: TObject; var Key: Word; Shift:
      TShiftState): Boolean; dynamic;
    {: This method is called whenever a mouse event is received.

       You don't need to use it.
    }
    function ViewOnDblClick(Sender: TObject): Boolean; dynamic;
    {: This method is called whenever a mouse event is received.

       You don't need to use it.
    }
    function ViewOnMouseMove(Sender: TObject; Shift:
      TShiftState; var X, Y: SmallInt): Boolean; dynamic;
    {: This method is called whenever a mouse event is received.

       You don't need to use it.
    }
    function ViewOnMouseDown(Sender: TObject; Button:
      TMouseButton; Shift: TShiftState; var X, Y: SmallInt):
      Boolean; dynamic;
    {: This method is called whenever a mouse event is received.

       You don't need to use it.
    }
    function ViewOnMouseUp(Sender: TObject; Button:
      TMouseButton; Shift: TShiftState; var X, Y: SmallInt):
      Boolean; dynamic;
    {: This method is used to send an event to the current state.

       You don't need to call it directly.
    }
    procedure SendEvent(Event: TCADPrgEvent; MouseButton:
      TCS4MouseButton; Shift: TShiftState; Key: Word); virtual;
    {: This property contains the current key pressed by the user and
       sent as the <I=Key> parameter of the <See Method=TCADState@OnEvent>.
    }
    property CurrentKey: Word read fCurrentKey write
      fCurrentKey;
    {: This property contains the linked viewport that is used to
       interact with the user.
    }
    property LinkedViewport: TCADViewport read fLinkedViewport
      write SetLinkedViewport;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {: This method starts a new interaction task.

       <I=StartState> is the class reference of the starting
       state class for the interaction task; <I=Param> is an instance
       of <See Class=TCADPrgParam> that will be the parameter
       of the interaction task (and it will be passed to all
       the state of it).

       If an interaction task is already active it will be stopped
       and the new one started. If it has a suspended interaction task
       the method returns <I=False> and the interaction start will not
       be started.

       The method returns <I=True> if the new interaction task is
       started.
    }
    function StartOperation(const StartState: TCADStateClass;
      Param: TCADPrgParam): Boolean;
    {: This method suspends the current interaction task and
       starts a new one.

       <I=StartState> is the class reference of the starting
       state class for the interaction task; <I=Param> is an instance
       of <See Class=TCADPrgParam> that will be the parameter
       of the interaction task (and it will be passed to all
       the state of it).

       If there is no active interaction task the new task will be
       simply started. If an interaction task was already suspended
       the method returns <I=False> and the new interaction start will
       not be started.

       The method returns <I=True> if the new interaction task is
       started.
    }
    function SuspendOperation(const StartState: TCADStateClass;
      Param: TCADPrgParam): Boolean;
    {: This method stops the current interaction task.

       If no interaction task is active the method does nothing.
    }
    procedure StopOperation;
    {: This method resets the FSM.

       Everithing is resetted as the control is created. Use this
       method only in case of unrecoverable errors.
    }
    procedure Reset;
    {: This method sends CAD event to the current state.

       It may be used to simulate mouse movements and operation
       (for instance to set a point with a value, you can set the
       <See Property=TCADPrg@CurrentViewportPoint> property to the
       point and send the <I=ceMouseDown> event).

       See <See Class=TCADState> for details.
    }
    procedure SendCADEvent(Event: TCADPrgEvent; MouseButton:
      TMouseButton; Shift: TShiftState; Key: Word);
    {: This method sends a user defined event to the current state.

      <I=Code> is the code for the user defined event. This code will
      be passed as the <I=Key> parameter to the
      <See Method=TCADState@OnEvent> method. The event can be identified
      in the code as a <I=ceUserDefined>.
    }
    procedure SendUserEvent(const Code: Word);
    {: If this method is called, the linked viewport will be
      repainted when the current interaction task will finish.

      <I=ARect> is the portion of the view plane to be repainted.

      By default when the current interaction task finishes only
      a refresh of the linked viewport is performed.

      See also <See Method=TCADPrg@RepaintAfterOperation>.
    }
    procedure RepaintRectAfterOperation(const ARect: TRect2D);
    {: If this method is called, the linked viewport will be
      repainted when the current interaction task will finish.

      By default when the current interaction task finishes only
      a refresh of the linked viewport is performed.

      See also <See Method=TCADPrg@RepaintRectAfterOperation>.
    }
    procedure RepaintAfterOperation;
    {: This property contains the current mouse position.
       The position is a 2D point that lies on the view plane of
       the linked viewport.

       Use this property inside the states to obtain the mouse
       position or set it to simulate mouse event by code.

       Other mouse position are defined depending on the type of
       the <I=CADPrg> (see also <See Class=TCADPrg2D> and
       <See Class=TCADPrg3D>).
    }
    property CurrentViewportPoint: TPoint2D read GetVPPoint write
      SetVPPoint;
    {: This property is <B=True> when there is an active interaction
       task in the control (that is its current state is not equal
       to the default state).
    }
    property IsBusy: Boolean read fIsBusy;
    {: This property is <B=True> when there is a suspended interaction
       task in the control.
    }
    property IsSuspended: Boolean read fIsSuspended;
    {: If this property is set to <B=True> then no event is sent to
       the active state of the control.

       This is very useful when you want to repaint a viewport inside
       a state but don't want to receive the <I=OnPaint> event.

       By default it is <B=False>.
    }
    property IgnoreEvents: Boolean read fIgnoreEvents write
      fIgnoreEvents;
    {: This propery contains the active state instance of the current
       interaction task.
    }
    property CurrentState: TCADState read fCurrentState;
    {: This propery contains the class reference type of the
       first state (that is the state passed to the
       <See Method=TCADPrg@StartOperation> or
       <See Method=TCADPrg@SuspendOperation> methods) for the
       current interaction task.
    }
    property CurrentOperation: TCADStateClass read
      fCurrentOperation write fCurrentOperation;
    {: This property contains a class reference value of the
       default state for the FSM.

       This is the state that will be instantiated whenever no
       interaction task is running. This state may be itself an
       interaction task that must be used to start other interaction
       tasks.

       By default the default state is <See Class=TCADIdleState>.
    }
    property DefaultState: TCADStateClass read fDefaultState
      write SetDefaultState;
    {: This is the linked viewport of the control.

       The linked viewport is the one that is able to send mouse
       and keyboard event to the <I=TCadPrg>. This control is used
       also as the output of the interaction task feedback and for
       the cursor visualization.
    }
    property Viewport: TCADViewport read fLinkedViewport;
    {: This property is the list that contains the picked
       objects.

       If you want to traverse the list ask for an iterator and
       remember to free it before to returns to the selection
       task.

       See also <See Class=TGraphicObjList>.
    }
  published
    {: If this property is <B=True> then the snapping constraint is
       enabled.

       The snapping used by the <I=TCADPrg> control is a 2D snapping
       on a plane. The plane on which it works depends on the kind
       of the control (see <See Class=TCADPrg2D> and <See Class=TCADPrg3D>).
    }
    property UseSnap: Boolean read fUseSnap write fUseSnap
      default False;
    {: If this property is <B=True> that the ortogonal constraint is
       enabled.

       The ortogonal constrain forces the drawing to be
       parallel to the X and Y axis of a plane. Not all
       interaction tasks uses this contraint that is any interaction
       tasks must implement its ortogonal contraint.
       The plane on which it works depends on the kind
       of the control (see <See Class=TCADPrg2D> and <See Class=TCADPrg3D>).
    }
    property UseOrto: Boolean read fUseOrto write fUseOrto
      default False;
    {: This property specifies the snapping step on the X axis of the
       interaction plane.

       See also <See Property=TCADPrg@UseSnap>.
    }
    property XSnap: TRealType read fSnapX write fSnapX;
    {: This property specifies the snapping step on the Y axis of the
       interaction plane.

       See also <See Property=TCADPrg@UseSnap>.
    }
    property YSnap: TRealType read fSnapY write fSnapY;
    {: This property contains the color of the cursor.

       The cursor is a visual feedback of the mouse position and
       must be implemented in specific <I=TCADPrg> controls
       (see <See Class=TCADPrg2D> and <See Class=TCADPrg3D>).
    }
    property CursorColor: TColor read fCursorColor write
      SetCursorColor default clGray;
    {: If this property is <B=True> then the cursor will be
       showed.

       The cursor is a visual feedback of the mouse position and
       must be implemented in specific <I=TCADPrg> controls
       (see <See Class=TCADPrg2D> and <See Class=TCADPrg3D>).
    }
    property ShowCursorCross: Boolean read fShowCursorCross write
      SetShowCursorCross default False;
    {: If this operation is <B=True> then the linked viewport of
       the control will be refreshed when the current operation
       finish. By default it is <B=True>.
    }
    property RefreshAfterOperation: Boolean read fRefreshAfterOp
      write fRefreshAfterOp default True;
    {: EVENTS}
    {: This property may contain an event-handler that is called
       when the current state is changed.

       It is called before the new state is entered.

       See also <See Type=TCADPrgOnChangeState>.
    }
    property OnEnterState: TCADPrgOnChangeState read fOnEntState
      write fOnEntState;
    {: This property may contain an event-handler that is called
       when the current state is changed.

       It is called after the state has exited.

       See also <See Type=TCADPrgOnChangeState>.
    }
    property OnExitState: TCADPrgOnChangeState read fOnExState
      write fOnExState;
    {: This property may contains an event-handler that is called
       when the current interaction task is ended.

       See also <See Type=TCADPrgOnOperation>.
    }
    property OnEndOperation: TCADPrgOnOperation read
      fOnEndOperation write fOnEndOperation;
    {: This property may contains an event-handler that is called
       when the current interaction task is stopped.

       See also <See Type=TCADPrgOnOperation>.
    }
    property OnStopOperation: TCADPrgOnOperation read fOnStop
      write fOnStop;
    {: This property may contains an event-handler that is called
       when a new interaction task is started.

       See also <See Type=TCADPrgOnOperation>.
    }
    property OnStartOperation: TCADPrgOnOperation read fOnStart
      write fOnStart;
    {: This property may contains an event-handler that is called
       when the control enter in the default state.
    }
    property OnIdle: TNotifyEvent read fOnIdle write fOnIdle;
    {: This property may contains an event-handler that is called
       when the description of the current state is changed.

       Use it to update the user information on the screen.
    }
    property OnDescriptionChanged: TNotifyEvent read
      fOnDescriptionChanged write fOnDescriptionChanged;
  end;

  TCADPrg2D = class;
  {: This type defines the type of a <I=2D mouse button filter>.

     A filter is a procedure that is called by a <I=TCADPrg> control
     to update the current mouse position of the control.

     <I=Sender> is the TCADPrg instance that has called the
     filter; <I=CurrentState> is the current state of the control;
     <I=Button> is the mouse button's state at the moment of the
     event; <I=WPt> must be set to new world point of the mouse
     position; <I=X, Y> are the mouse position in screen coordinates.

     A filter is useful to change the position of a mouse event
     before the event is handled by the current state. For example
     it may be used to implement an object gravity function by
     calling in the filter the PickObject method of the linked
     viewport and if the WPt point is on an object change it to
     the nearest control point of the object.

     <B=Note>: <I=WPt> contains the current world point of the
      mouse position at the moment of the activation of the filter.
      So if you don't need to change it simply left it unchanged.
  }
  TMouse2DButtonFilter = procedure(Sender: TCADPrg2D;
    CurrentState: TCADState; Button: TMouseButton; var WPt:
    TPoint2D; X, Y: Integer) of object;
  {: This type defines the type of a <I=2D mouse move filter>.

     A filter is a procedure that is called by a <I=TCADPrg> control
     to update the current mouse position of the control.

     <I=Sender> is the TCADPrg instance that has called the
     filter; <I=CurrentState> is the current state of the control;
     <I=Button> is the mouse button's state at the moment of the
     event; <I=WPt> must be set to new world point of the mouse
     position; <I=X, Y> are the mouse position in screen coordinates.

     A filter is useful to change the position of a mouse event
     before the event is handled by the current state. For example
     it may be used to implement an object gravity function by
     calling in the filter the PickObject method of the linked
     viewport and if the WPt point is on an object change it to
     the nearest control point of the object.

     <B=Note>: <I=WPt> contains the current world point of the
      mouse position at the moment of the activation of the filter.
      So if you don't need to change it simply left it unchanged.
  }
  TMouse2DMoveFilter = procedure(Sender: TCADPrg2D;
    CurrentState: TCADState; var WPt: TPoint2D; X, Y: Integer)
    of
    object;
  {: This type defines the type of a <I=2D snap filter>.

     A filter is a procedure that is called by a <I=TCADPrg> control
     to update the current mouse position of the control.

     <I=Sender> is the TCADPrg instance that has called the
     filter; <I=CurrentState> is the current state of the control;
     <I=LastPt> contains the snap origin for the snapping;
     <I=CurrSnappedPt> must be set to the new snapped point.

     A snap filter is useful to implement complex snapping
     constraint. For instance you may create an angular snapping
     by using the <I=LastPt> and <I=CurrSnappedPt> to find the
     current angle and then forces it to the nearest allowed angle.

     When the filter is activated <I=LastPt> contains the snap origin,
     that is the value assigned to the <See Property=TCADPrg2D@SnapOriginPoint>
     property. If there is no valid snap origin then
     it will be (<I=MaxCoord>, <I=MaxCoord>). You must check for this
     value when implement a snap filter.

     By default the <I=CurrSnappedPt> will be the standar snapped
     point that is the point with the X and Y coordinates at integer
     multiplies of <I=XSnap> and <I=YSnap>.
  }
  TCADPrg2DSnapFilter = procedure(Sender: TCADPrg2D;
    CurrentState: TCADState; const LastPt: TPoint2D; var
    CurrSnappedPt: TPoint2D) of object;

  {: This type define the class type used to specify a <See Class=TCADState2D> class.
  }
  TCADStateClass2D = class of TCADState2D;

  {: This class defines a state of a interaction task.

     <See Class=TCADPrg> is based on a <I=FSM model> (finite state
     machine) in which an interaction task is is a set of states,
     each of them execute some part of the whole task.
     The interaction task (from now on simply a task) evolves through
     the states in respons to <I=events>. An <I=event> is some action
     on the CADPrg or the linked Viewport performed by the user or
     by the control itself.
     A task is an <I=active state>, that is the state with receives
     the events (through the implementation of the
     <See Method=TCADState@OnEvent>).
     The active state decides what operation performs in response to
     the event. See <See Method=TCADState@OnEvent> for details.

     The events are (see also TCADPrgEvent) <I=mouse events, keyboard
     events, expose events and user events>.

     The user must derives its states from this class to implement
     an interaction task. A state may be reused in more that one
     interaction task.

     An interaction task is started by using the
     <See Method=TCADPrg@StartOperation>,
     <See Method=TCADPrg@SuspendOperation> and passing it the first
     state of it.

     To define a state you may want to implement the following
     methods:

     <LI=<See Method=TCADState@Create> in which you place the
       initialization code for the state>
     <LI=<See Method=TCADState@OnEvent> in which you place the
       code to handle the events>
     <LI=<See Method=TCADState@OnStop> in which you plane the
       finalization code for the interaction task (this method
       is called when an interaction task is stopped, no when
       the state instace is destroyed.>

     <B=Note>: The instance of a state is created by the <See Class=TCADPrg>
      control.
  }
  TCADState2D = class(TCADState);

  {: This class defines the control used by the library to handle 2D
     interaction tasks. An interaction task is an interactive
     visual sequence of operation on a Viewport.

     The control implement a FSM (Finite state machine) model
     that receives events from the user and the Viewport.

     The <I=TCADPrg2D> control use points on the view plane of
     the linked viewport.

     See also <See Class=TCADState2D> class for details.
  }
  TCADPrg2D = class(TCADPrg)
  private
    fCurrentViewportPoint: TPoint2D;
    fLastCursorPos, fSnapOriginPoint: TPoint2D;
    fMouseButtonFilter: TMouse2DButtonFilter;
    fMouseMoveFilter: TMouse2DMoveFilter;
    fSnapFilter: TCADPrg2DSnapFilter;

    procedure SetViewport2D(View2D: TCADViewport2D);
    function GetViewport2D: TCADViewport2D;
  protected
    function ViewOnMouseMove(Sender: TObject; Shift:
      TShiftState; var X, Y: SmallInt): Boolean; override;
    function ViewOnMouseDown(Sender: TObject; Button:
      TMouseButton; Shift: TShiftState; var X, Y: SmallInt):
      Boolean; override;
    function ViewOnMouseUp(Sender: TObject; Button:
      TMouseButton; Shift: TShiftState; var X, Y: SmallInt):
      Boolean; override;
    {: This method draws an hair crossed 2D cursor on the view plane
       in xor mode.
    }
    procedure DrawCursorCross; override;
    {: This method hides an hair crossed 2D cursor on the view plane
       in xor mode.
    }
    procedure HideCursorCross; override;
    function GetVPPoint: TPoint2D; override;
    procedure SetVPPoint(const PT: TPoint2D); override;
    function GetVPSnappedPoint: TPoint2D;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {: This property contains the current snapped position of the
       mouse.

       Use this property to know the mouse position on the view
       plane of the last mouse event.

       <B=Note>: It is better to use this property in your interaction
       tasks instead of the <See Property=TCADPrg@CurrentViewportPoint>
       property because by using this property you automatically apply
       the snapping if enabled.
    }
    property CurrentViewportSnappedPoint: TPoint2D read
      GetVPSnappedPoint;
    {: This property contains the snap origin passed to the snap filter.

       By default its value is (<I=MaxCoord>, <I=MaxCoord>).

       See <See Type=TCADPrg2DSnapFilter> for details.
    }
    property SnapOriginPoint: TPoint2D read fSnapOriginPoint
      write fSnapOriginPoint;
  published
    {: This property contains the linked viewport.

       See also <See Property=TCADPrg@Viewport>.
    }
    property Viewport2D: TCADViewport2D read GetViewport2D write
      SetViewport2D;
    {: This property may contains a filter that will be called
       when a mouse button event is fired.

       See also <See Type=TMouse2DButtonFilter>.
    }
    property MouseButtonFilter: TMouse2DButtonFilter read
      fMouseButtonFilter write fMouseButtonFilter;
    {: This property may contains a filter that will be called
       when a mouse movement event is fired.

       See also <See Type=TMouse2DMoveFilter>.
    }
    property MouseMoveFilter: TMouse2DMoveFilter read
      fMouseMoveFilter write fMouseMoveFilter;
    {: This property may contains a filter that will be called
       when a the snapped point of the current mouse position
       is being computed.

       See also <See Type=TCADPrg2DSnapFilter>.
    }
    property SnapFilter: TCADPrg2DSnapFilter read fSnapFilter
      write fSnapFilter;
  end;

  { The below class utilities are for graphics object registration. }
  {: This procedure resets the list of graphic object registrations.

     See also <See=Object's Persistance@PERSISTANCE>.
  }
procedure CADSysInitClassRegister;
  {: This function search for the index of the registered
     graphic object. If no match is found it returns -1.

     See also <See=Object's Persistance@PERSISTANCE>.
  }
function CADSysFindClassIndex(const Name: string): Word;
  {: This function search for the index of the registered
     graphic object by using its class name. If no match is
     found it returns -1.

     See also <See=Object's Persistance@PERSISTANCE>.
  }
function CADSysFindClassByName(const Name: string):
  TGraphicObjectClass;
  {: This function returns the class reference of the graphic
     object which the specified registration index.

     See also <See=Object's Persistance@PERSISTANCE>.
  }
function CADSysFindClassByIndex(Index: Word):
  TGraphicObjectClass;
  {: This procedure registers a new graphic object class in the
     library PERSISTANCE system.

     This method must be used to register your owns graphical
     object classes so that they can be streamed to a drawing
     file automatically by the library.

     <I=Index> is the registration index you choose.
     If a class is already registered in that slot an exception
     will be raised. It is better to register your classe from
     the index 150 on.

     There are <I=MAX_REGISTERED_CLASSES> slots in the
     registration list.

     See also <See=Object's Persistance@PERSISTANCE>.
  }
procedure CADSysRegisterClass(Index: Word; const GraphClass:
  TGraphicObjectClass);
  {: This procedure unregisters a graphic object class in the
     library PERSISTANCE system.

     <I=Index> is the registration index to clear.

     See also <See=Object's Persistance@PERSISTANCE>.
  }
procedure CADSysUnregisterClass(Index: Word);
  {: This function converts a pascal string to a <I=source block>
     name type.

     See also <See Type=TSourceBlockName>
  }
function StringToBlockName(const Str: string): TSourceBlockName;

procedure Register;

const
  {: This constant contains the version number of the library
     used as drawing file's header.
  }
  CADSysVersion: TCADVersion = 'CAD422';
  {: This constant is used as <I=drawing mode> value for
     the <See Property=TCADViewport@DrawMode>.
  }
  DRAWMODE_NORMAL = 0;
  {: This constant is used as <I=drawing mode> value for
     the <See Property=TCADViewport@DrawMode>.

     The <I=draw mode> values used as toogle flags. If this
     value is present in the DrawMode property no drawing
     will produced.
  }
  DRAWMODE_NODRAW = 1;
  {: This constant is used as <I=drawing mode> value for
     the <See Property=TCADViewport@DrawMode>.

     The <I=draw mode> values used as toogle flags. If this
     value is present in the DrawMode property the object
     are drawed with their control points.

     <B=Note>: Your drawing shape classess must understands these
     flags and behaves accordingly.
  }
  DRAWMODE_SHOWCTRLPOINTS = 2;
  {: This constant is used as <I=drawing mode> value for
     the <See Property=TCADViewport@DrawMode>.

     The <I=draw mode> values used as toogle flags. If this
     value is present in the DrawMode property only front
     facing planar object will be drawed (only for 3D viewports).

     The font facing check is <B=True> if the ray from the
     camera position to the view point is opposite to the face
     normal (ie you are looking the font face).

     <B=Note>: Your drawing shape classess must understands these
     flags and behaves accordingly.
  }
  {: This constant is used as <I=drawing mode> value for
     the <See Property=TCADViewport@DrawMode>.

     The <I=draw mode> values used as toogle flags. If this
     value is present in the DrawMode property the vectorial
     text objects will be drawed with only their bounding
     boxes.

     <B=Note>: Your drawing shape classess must understands these
     flags and behaves accordingly.
  }
  DRAWMODE_VECTTEXTONLYBOX = 32;

  //TSY:
  DRAWMODE_OutlineOnly = 64;

  {:
  }
  MAX_REGISTERED_CLASSES = 512;

  {: This commands stops the current task with success.

     See also <See Method=TCADPrg@SendUserEvent>.
  }
  CADPRG_ACCEPT = 1;
  {: This commands aborts the current task.

     See also <See Method=TCADPrg@SendUserEvent>.
  }
  CADPRG_CANCEL = CADPRG_ACCEPT + 1;

function GetExtension0(Drawing2D: TDrawing2D;
  Iter: TGraphicObjIterator): TRect2D;

procedure BitmapToPNG(const aBitmap: TBitmap;
  const FileName: string);

implementation

uses Math, Dialogs, Forms, CS4Shapes, pngimage, SysBasic,
  ClpbrdOp, ColorEtc;


function MD5Stream(const AStream: TStream): TCheckSum;
var
  Context: MD5Context;
  Buffer: array[0..4095] of Byte;
  Len: Integer;
begin
  MD5Init(Context);
  AStream.Seek(0, soFromBeginning);
  repeat
    Len := AStream.Read(Buffer, 4096);
    if Len > 0 then MD5Update(Context, @Buffer, Len);
  until Len = 0;
  MD5Final(Context, Result);
end;

procedure MD5Stream_try(const St: string);
var
  AStream: TStringStream;
  CheckSum: TCheckSum;
begin
  Application.MessageBox(PChar(MD5Print(MD5String(St))), nil);
  //Exit;
  AStream := TStringStream.Create(St);
  CheckSum := MD5Stream(AStream);
  AStream.Free;
  Application.MessageBox(PChar(MD5Print(CheckSum)), nil);
end;

type
  TPaintingThread = class(TThread)
  private
    { Private declarations }
    fOwner: TCADViewport;
    fRect: TRect2D;
  public
    // Assign also the OnTerminate event.
    constructor Create(const Owner: TCADViewport; const ARect:
      TRect2D);
    destructor Destroy; override;

    procedure Execute; override;
  end;

  TGraphicClassRegistered = array[0..512] of
    TGraphicObjectClass;

  PObjBlock = ^TObjBlock;

  TObjBlock = record
    Obj: TGraphicObject; { Graphic object. }
    Next, Prev: PObjBlock; { Linked list pointer. }
  end;

var
  GraphicObjectsRegistered: TGraphicClassRegistered;

procedure Register;
begin
  RegisterComponents('TpX', [TRuler, TDrawing2D,
    TCADViewport2D, TCADPrg2D]);
end;

// =====================================================================
// TGraphicObject
// =====================================================================

constructor TGraphicObject.Create(ID: Integer);
begin
  inherited Create;

  fID := ID;
  fLayer := 0;
  fVisible := True;
  fEnabled := True;
  fToBeSaved := True;
  fTag := 0;
  fOnChange := nil;
end;

constructor TGraphicObject.CreateFromStream(const Stream:
  TStream; const Version: TCADVersion);
var
  BitMask: Byte;
begin
  inherited Create;
  with Stream do
  begin
    Read(fID, SizeOf(fID));
    Read(fLayer, SizeOf(fLayer));
    Read(BitMask, SizeOf(BitMask))
  end;
  fVisible := (BitMask and 1) = 1;
  fEnabled := (BitMask and 2) = 2;
  fToBeSaved := not ((BitMask and 4) = 4);
  fTag := 0;
  fOnChange := nil;
end;

constructor TGraphicObject.CreateDupe(Obj: TGraphicObject);
begin
  inherited Create;
  fID := -1;
  fLayer := 0;
  fVisible := True;
  fEnabled := True;
  fToBeSaved := True;
  fTag := 0;
  fOnChange := nil;
  Assign(Obj);
end;

procedure TGraphicObject.SaveToStream(const Stream: TStream);
var
  BitMask: Byte;
begin
  BitMask := 0;
  if fVisible then BitMask := BitMask or 1;
  if fEnabled then BitMask := BitMask or 2;
  if not fToBeSaved then
    BitMask := BitMask or 4;
      // Uso il not per compatibilitÓ con le versioni precedenti.
  with Stream do
  begin
    Write(fID, SizeOf(fID));
    Write(fLayer, SizeOf(fLayer));
    Write(BitMask, SizeOf(BitMask));
  end;
end;

procedure TGraphicObject.Assign(const Obj: TGraphicObject);
begin
  if (Obj = Self) then
    Exit;
  fVisible := Obj.Visible;
  fEnabled := Obj.Enabled;
  fToBeSaved := Obj.ToBeSaved;
end;

procedure TGraphicObject.UpdateExtension(Sender: TObject);
begin
  _UpdateExtension;
  if Assigned(fOnChange) then
    fOnChange(Self);
end;

// =====================================================================
// Registration functions
// =====================================================================

function CADSysFindClassIndex(const Name: string): Word;
var
  Cont: Integer;
begin
  for Cont := 0 to MAX_REGISTERED_CLASSES - 1 do
    if Assigned(GraphicObjectsRegistered[Cont]) and
      (GraphicObjectsRegistered[Cont].ClassName = Name) then
    begin
      Result := Cont;
      Exit;
    end;
  raise ECADObjClassNotFound.Create('CADSysFindClassIndex: ' +
    Name + ' graphic class not found');
end;

function CADSysFindClassByName(const Name: string):
  TGraphicObjectClass;
begin
  Result :=
    GraphicObjectsRegistered[CADSysFindClassIndex(Name)];
end;

function CADSysFindClassByIndex(Index: Word):
  TGraphicObjectClass;
begin
  if Index >= MAX_REGISTERED_CLASSES then
    raise
      Exception.Create(
      Format('CADSysRegisterClass: Out of bound registration index %d',
      [Index]));
  if not Assigned(GraphicObjectsRegistered[Index]) then
    raise
      ECADObjClassNotFound.Create(
      Format('CADSysFindClassByIndex: Index not registered %d',
      [Index]));
  Result := GraphicObjectsRegistered[Index];
end;

procedure CADSysRegisterClass(Index: Word; const GraphClass:
  TGraphicObjectClass);
begin
  if Index >= MAX_REGISTERED_CLASSES then
    raise
      Exception.Create('CADSysRegisterClass: Out of bound registration index');
  if Assigned(GraphicObjectsRegistered[Index]) then
    raise
      ECADObjClassNotFound.Create(Format('CADSysRegisterClass: Index %d already allocated by %s', [Index, GraphicObjectsRegistered[Index].ClassName]));
  GraphicObjectsRegistered[Index] := GraphClass;
end;

procedure CADSysUnregisterClass(Index: Word);
begin
  if Index >= MAX_REGISTERED_CLASSES then
    raise
      Exception.Create('CADSysRegisterClass: Out of bound registration index');
  if Assigned(GraphicObjectsRegistered[Index]) then
    GraphicObjectsRegistered[Index] := nil;
end;

procedure CADSysInitClassRegister;
var
  Cont: Word;
begin
  for Cont := 0 to MAX_REGISTERED_CLASSES do
    GraphicObjectsRegistered[Cont] := nil;
end;

// =====================================================================
// TGraphicObjList
// =====================================================================

constructor TGraphicObjList.Create;
begin
  inherited Create;

  fListGuard := TCADSysCriticalSection.Create;
  fHead := nil;
  fTail := nil;
  fIterators := 0;
  fHasExclusive := False;
  fCount := 0;
  fFreeOnClear := True;
end;

destructor TGraphicObjList.Destroy;
var
  TmpBlock: PObjBlock;
begin
  while fHead <> nil do
  begin
    try
      if fFreeOnClear and Assigned(TObjBlock(fHead^).Obj) then
        TObjBlock(fHead^).Obj.Free;
    except
    end;
    TmpBlock := fHead;
    fHead := TObjBlock(fHead^).Next;
    FreeMem(TmpBlock, SizeOf(TObjBlock));
  end;
  fListGuard.Free;
  inherited;
end;

function TGraphicObjList.GetHasIter: Boolean;
begin
  Result := fIterators > 0;
end;

function TGraphicObjList.GetIterator: TGraphicObjIterator;
begin
  if fHasExclusive then
    raise
      ECADListBlocked.Create('TGraphicObjList.GetIterator: The list has exclusive iterator.');
  Result := TGraphicObjIterator.Create(Self);
end;

function TGraphicObjList.GetExclusiveIterator:
  TExclusiveGraphicObjIterator;
begin
  if fIterators > 0 then
    raise
      ECADListBlocked.Create('TGraphicObjList.GetExclusiveIterator: The list has active iterators.');
  Result := TExclusiveGraphicObjIterator.Create(Self);
end;

function TGraphicObjList.GetPrivilegedIterator:
  TExclusiveGraphicObjIterator;
begin
  Result := TExclusiveGraphicObjIterator.Create(Self);
end;

procedure TGraphicObjList.RemoveAllIterators;
begin
  fListGuard.Enter;
  try
    fIterators := 0;
    fHasExclusive := False;
  finally
    fListGuard.Leave;
  end;
end;

procedure TGraphicObjList.TransForm(const T: TTransf2D);
var
  ExIter: TExclusiveGraphicObjIterator;
  Current: TGraphicObject;
begin
  ExIter := GetExclusiveIterator;
  try
    Current := ExIter.First;
    while Assigned(Current) do
    begin
      if Current is TObject2D then
        (Current as TObject2D).TransForm(T);
      Current := ExIter.Next;
    end;
  finally
    ExIter.Free;
  end;
end;

function TGraphicObjList.PickObject(const PT: TPoint2D;
  Drawing: TDrawing2D; const Aperture: TRealType;
  const VisualRect: TRect2D; const DrawMode: Integer;
  const FirstFound: Boolean; var NPoint: Integer): TObject2D;
var
  TmpNPoint: Integer;
  Tmp: TObject2D;
  MinDist, Distance: TRealType;
  TmpIter: TExclusiveGraphicObjIterator;
  //TSY:
  function NPointLevel(const NPoint: Integer): TRealType;
  begin
    Result := NPoint;
    if NPoint > -2 then Result := -2;
  end;
begin
  Result := nil;
  if Drawing = nil then Exit;
  TmpIter := GetExclusiveIterator;
  try
    MinDist := Aperture;
    NPoint := PICK_NOOBJECT;
    Tmp := TmpIter.Current as TObject2D;
    while Tmp <> nil do
      with (Drawing.Layers[Tmp.Layer]) do
      begin
        if Active and Visible {and (Tmp is fPickFilter)} and
          Tmp.IsVisible(VisualRect, DrawMode) then
        begin
          TmpNPoint := Tmp.OnMe(PT, Aperture, Distance);
          //TSY:
          //if TmpNPoint = -2 then Distance := 0;
          if (NPointLevel(TmpNPoint) >= NPointLevel(NPoint))
            and (Distance <= MinDist) then
          begin
            Result := Tmp;
            NPoint := TmpNPoint;
            MinDist := Distance;
            if FirstFound then
              Break;
          end;
        end;
        Tmp := TmpIter.Next as TObject2D;
      end;
  finally
    TmpIter.Free;
  end;
end;

procedure TGraphicObjList.Add(const Obj: TGraphicObject);
var
  NewBlock: PObjBlock;
begin
  if fIterators > 0 then
    raise
      ECADListBlocked.Create('TGraphicObjList.Add: The list has active iterators.');
  fListGuard.Enter;
  try
    { Allocate new blocks. }
    GetMem(NewBlock, SizeOf(TObjBlock));
    { Initialize the block. }
    NewBlock^.Prev := fTail;
    NewBlock^.Next := nil;
    NewBlock^.Obj := Obj;
    if fHead = nil then
      fHead := NewBlock;
    if fTail <> nil then
      TObjBlock(fTail^).Next := NewBlock;
    fTail := NewBlock;
    Inc(fCount);
  finally
    fListGuard.Leave;
  end;
end;

procedure TGraphicObjList.AddFromList(const Lst:
  TGraphicObjList);
var
  TmpIter: TGraphicObjIterator;
  I: Integer;
begin
  if Lst.Count = 0 then
    Exit;
  if fIterators > 0 then
    raise
      ECADListBlocked.Create('TGraphicObjList.AddFromList: The list has active iterators.');
  // Alloca un iterator locale
  fListGuard.Enter;
  try
    TmpIter := Lst.GetIterator;
    I := 0;
    try
      repeat
        Add(TmpIter.Current);
        Inc(I);
        if I mod 100 = 0 then ShowProgress(I / Lst.Count);
      until TmpIter.Next = nil;
    finally
      TmpIter.Free;
    end;
  finally
    fListGuard.Leave;
  end;
end;

procedure TGraphicObjList.Insert(const IDInsertPoint: Integer;
  const Obj: TGraphicObject);
var
  NewBlock: PObjBlock;
  InsertPoint: PObjBlock;
  TmpIter: TExclusiveGraphicObjIterator;
begin
  { Safe guard. }
  if fHead = nil then
    raise
      ECADSysException.Create('TGraphicObjList.Insert: No objects in the list');
  if fIterators > 0 then
    raise
      ECADListBlocked.Create('TGraphicObjList.Insert: The list has active iterators.');
  // Alloca un iterator locale
  TmpIter := GetExclusiveIterator;
  try
    InsertPoint := TmpIter.SearchBlock(IDInsertPoint);
    if (InsertPoint = nil) then
      raise
        ECADListObjNotFound.Create('TGraphicObjList.Insert: Object not found');
    { Allocate new blocks. }
    GetMem(NewBlock, SizeOf(TObjBlock));
    { Initialize the block. }
    NewBlock^.Prev := InsertPoint^.Prev;
    NewBlock^.Next := InsertPoint;
    NewBlock^.Obj := Obj;
    if InsertPoint^.Prev <> nil then
      InsertPoint^.Prev^.Next := NewBlock
    else
      fHead := NewBlock;
    InsertPoint^.Prev := NewBlock;
    Inc(fCount);
  finally
    TmpIter.Free;
  end;
end;

procedure TGraphicObjList.Move(const IDToMove, IDInsertPoint:
  Integer);
var
  InsertPoint, ToMove: PObjBlock;
  TmpIter: TExclusiveGraphicObjIterator;
begin
  { Safe guard. }
  if fHead = nil then
    raise
      ECADSysException.Create('TGraphicObjList.Move: No objects in the list');
  if fIterators > 0 then
    raise
      ECADListBlocked.Create('TGraphicObjList.Move: The list has active iterators.');
  // Alloca un iterator locale
  TmpIter := GetExclusiveIterator;
  try
    { Check if the current and insert point are the same. }
    if IDInsertPoint = IDToMove then
      raise
        ECADSysException.Create('TGraphicObjList.Move: Bad object to move');
    InsertPoint := TmpIter.SearchBlock(IDInsertPoint);
    ToMove := TmpIter.SearchBlock(IDToMove);
    if (InsertPoint = nil) then
      raise
        ECADListObjNotFound.Create('TGraphicObjList.Move: Insertion point not found');
    if (ToMove = nil) then
      raise
        ECADListObjNotFound.Create('TGraphicObjList.Move: Object to move not found');
    { Now I have the block to move and the insertion point. }
    if ToMove^.Prev <> nil then
      ToMove^.Prev^.Next := ToMove^.Next
    else
      fHead := ToMove^.Next;
    if ToMove^.Next <> nil then
      ToMove^.Next^.Prev := ToMove^.Prev
    else
      fTail := ToMove^.Prev;
    { Set new link. }
    if InsertPoint^.Prev <> nil then
      InsertPoint^.Prev^.Next := ToMove
    else
      fHead := ToMove;
    ToMove^.Next := InsertPoint;
    ToMove^.Prev := InsertPoint^.Prev;
    InsertPoint^.Prev := ToMove;
  finally
    TmpIter.Free;
  end;
end;

procedure TGraphicObjList.DeleteBlock(ObjToDel: Pointer);
begin
  fListGuard.Enter;
  try
    // Free the first object. So if it cannot be deleted it will be later.
    if Assigned(TObjBlock(ObjToDel^).Obj) and fFreeOnClear then
      TObjBlock(ObjToDel^).Obj.Free;
    // First extract the block from all list.
    if TObjBlock(ObjToDel^).Next <> nil then
      TObjBlock(ObjToDel^).Next^.Prev :=
        TObjBlock(ObjToDel^).Prev
    else
     { I reached the Last block. }
      fTail := TObjBlock(ObjToDel^).Prev;
    if TObjBlock(ObjToDel^).Prev <> nil then
      TObjBlock(ObjToDel^).Prev^.Next :=
        TObjBlock(ObjToDel^).Next
    else
     { I reached the head. }
      fHead := TObjBlock(ObjToDel^).Next;
    FreeMem(ObjToDel, SizeOf(TObjBlock));
    Dec(fCount);
  finally
    fListGuard.Leave;
  end;
end;

function TGraphicObjList.Delete(const ID: Integer): Boolean;
var
  ObjToDel: PObjBlock;
  TmpIter: TExclusiveGraphicObjIterator;
begin
  Result := False;
  if fIterators > 0 then
    raise
      ECADListBlocked.Create('TGraphicObjList.Delete: The list has active iterators.');
  // Alloca un iterator locale
  TmpIter := GetExclusiveIterator;
  try
    ObjToDel := TmpIter.SearchBlock(ID);
    if ObjToDel = nil then
      raise
        ECADListObjNotFound.Create('TGraphicObjList.Delete: Object not found');
    DeleteBlock(ObjToDel);
    Result := True;
  finally
    TmpIter.Free;
  end;
end;

function TGraphicObjList.Find(const ID: Integer):
  TGraphicObject;
var
  FoundObj: PObjBlock;
  TmpIter: TGraphicObjIterator;
begin
  Result := nil;
  // Alloca un iterator locale
  TmpIter := GetIterator;
  try
    FoundObj := TmpIter.SearchBlock(ID);
    if FoundObj = nil then
      Exit;
    Result := TObjBlock(FoundObj^).Obj;
  finally
    TmpIter.Free;
  end;
end;

procedure TGraphicObjList.RemoveBlock(ObjToDel: Pointer);
begin
  fListGuard.Enter;
  try
    // First extract the block from all list.
    if TObjBlock(ObjToDel^).Next <> nil then
      TObjBlock(ObjToDel^).Next^.Prev :=
        TObjBlock(ObjToDel^).Prev
    else
     { I reached the Last block. }
      fTail := TObjBlock(ObjToDel^).Prev;
    if TObjBlock(ObjToDel^).Prev <> nil then
      TObjBlock(ObjToDel^).Prev^.Next :=
        TObjBlock(ObjToDel^).Next
    else
     { I reached the head. }
      fHead := TObjBlock(ObjToDel^).Next;
    FreeMem(ObjToDel, SizeOf(TObjBlock));
    Dec(fCount);
  finally
    fListGuard.Leave;
  end;
end;

function TGraphicObjList.Remove(const ID: Integer): Boolean;
var
  ObjToDel: PObjBlock;
  TmpIter: TExclusiveGraphicObjIterator;
begin
  Result := False;
  if fIterators > 0 then
    raise
      ECADListBlocked.Create('TGraphicObjList.Remove: The list has active iterators.');
  // Alloca un iterator locale
  TmpIter := GetExclusiveIterator;
  try
    ObjToDel := TmpIter.SearchBlock(ID);
    if ObjToDel = nil then
      raise
        ECADListObjNotFound.Create('TGraphicObjList.Remove: No object found');
    RemoveBlock(ObjToDel);
    Result := False;
  finally
    TmpIter.Free;
  end;
end;

procedure TGraphicObjList.Clear;
var
  TmpBlock: PObjBlock;
begin
  if fIterators > 0 then
    raise
      ECADListBlocked.Create('TGraphicObjList.Clear: The list has active iterators.');
  fListGuard.Enter;
  try
    while fHead <> nil do
    begin
      try
        if fFreeOnClear and Assigned(TObjBlock(fHead^).Obj) then
          TObjBlock(fHead^).Obj.Free;
      except
      end;
      TmpBlock := fHead;
      fHead := TObjBlock(fHead^).Next;
      FreeMem(TmpBlock, SizeOf(TObjBlock));
    end;
    fHead := nil;
    fTail := nil;
    fCount := 0;
  finally
    fListGuard.Leave;
  end;
end;

// =====================================================================
// TGraphicObjIterator
// =====================================================================

{ Search the block corresponding to ID. }

function TGraphicObjIterator.SearchBlock(ID: Integer): Pointer;
begin
  Result := fSourceList.fHead;
  while (Result <> nil) and (TObjBlock(Result^).Obj.ID <> ID) do
  begin
    if TObjBlock(Result^).Prev = fSourceList.fTail then
    begin
      Result := nil;
      Break;
    end;
    Result := TObjBlock(Result^).Next;
  end;
end;

function TGraphicObjIterator.GetCurrentObject: TGraphicObject;
begin
  if fCurrent <> nil then
    Result := TObjBlock(fCurrent^).Obj
  else
    Result := nil;
end;

constructor TGraphicObjIterator.Create(const Lst:
  TGraphicObjList);
begin
  inherited Create;

  Lst.fListGuard.Enter;
  try
    fCurrent := nil;
    fSourceList := Lst;
    if fSourceList <> nil then
    begin
      Inc(fSourceList.fIterators);
      fCurrent := fSourceList.fHead;
    end;
  finally
    Lst.fListGuard.Leave;
  end;
end;

destructor TGraphicObjIterator.Destroy;
begin
  fSourceList.fListGuard.Enter;
  try
    if fSourceList <> nil then
    begin
      Dec(fSourceList.fIterators);
      if fSourceList.fIterators < 0 then
        fSourceList.fIterators := 0;
    end;
  finally
    fSourceList.fListGuard.Leave;
  end;
  inherited;
end;

function TGraphicObjIterator.GetCount: Integer;
begin
  if (fSourceList = nil) then
    Result := 0
  else
    Result := fSourceList.Count;
end;

function TGraphicObjIterator.Search(const ID: Integer):
  TGraphicObject;
var
  TmpBlock: PObjBlock;
begin
  Result := nil;
  if (fSourceList = nil) then
    Exit;
  TmpBlock := SearchBlock(ID);
  if TmpBlock = nil then
    Exit;
  Result := TmpBlock^.Obj;
  fCurrent := TmpBlock;
end;

function TGraphicObjIterator.Next: TGraphicObject;
begin
  Result := nil;
  if (fSourceList = nil) and (fCurrent = nil) then
    Exit;
  { Check if the End of the list is reached. }
  if fCurrent = Pointer(fSourceList.fTail) then
  begin
    fCurrent := nil;
    Exit;
  end;
  fCurrent := TObjBlock(fCurrent^).Next;
  Result := TObjBlock(fCurrent^).Obj;
end;

function TGraphicObjIterator.Prev: TGraphicObject;
begin
  Result := nil;
  if (fSourceList = nil) and (fCurrent = nil) then
    Exit;
  { Check if the start of the list is reached. }
  if fCurrent = Pointer(fSourceList.fHead) then
  begin
    fCurrent := nil;
    Exit;
  end;
  fCurrent := TObjBlock(fCurrent^).Prev;
  Result := TObjBlock(fCurrent^).Obj;
end;

function TGraphicObjIterator.First: TGraphicObject;
begin
  Result := nil;
  if fSourceList = nil then
    Exit;
  fCurrent := fSourceList.fHead;
  if fCurrent = nil then
    Exit;
  Result := TObjBlock(fCurrent^).Obj;
end;

function TGraphicObjIterator.Last: TGraphicObject;
begin
  Result := nil;
  if fSourceList = nil then
    Exit;
  fCurrent := fSourceList.fTail;
  if fCurrent = nil then
    Exit;
  Result := TObjBlock(fCurrent^).Obj;
end;

// =====================================================================
// TExclusiveGraphicObjIterator
// =====================================================================

constructor TExclusiveGraphicObjIterator.Create(const Lst:
  TGraphicObjList);
begin
  inherited Create(Lst);
  Lst.fListGuard.Enter;
  try
    if fSourceList <> nil then
      fSourceList.fHasExclusive := True;
  finally
    Lst.fListGuard.Leave;
  end;
end;

destructor TExclusiveGraphicObjIterator.Destroy;
begin
  fSourceList.fListGuard.Enter;
  try
    if fSourceList <> nil then
      fSourceList.fHasExclusive := False;
  finally
    fSourceList.fListGuard.Leave;
  end;
  inherited;
end;

procedure TExclusiveGraphicObjIterator.DeleteCurrent;
var
  TmpObj: Pointer;
begin
  if (fSourceList <> nil) and (fCurrent <> nil) then
  begin
    if TObjBlock(fCurrent^).Next <> nil then
      TmpObj := TObjBlock(fCurrent^).Next
    else
      TmpObj := TObjBlock(fCurrent^).Prev;
    fSourceList.DeleteBlock(fCurrent);
    fCurrent := TmpObj;
  end;
end;

procedure TExclusiveGraphicObjIterator.RemoveCurrent;
var
  TmpObj: Pointer;
begin
  if (fSourceList <> nil) and (fCurrent <> nil) then
  begin
    if TObjBlock(fCurrent^).Next <> nil then
      TmpObj := TObjBlock(fCurrent^).Next
    else
      TmpObj := TObjBlock(fCurrent^).Prev;
    fSourceList.RemoveBlock(fCurrent);
    fCurrent := TmpObj;
  end;
end;

procedure TExclusiveGraphicObjIterator.ReplaceDeleteCurrent(
  const Obj: TGraphicObject);
var
  OwnerCAD: TDrawing;
begin
  if (fSourceList = nil) or (fCurrent = nil) then Exit;
  OwnerCAD := nil;
  if Assigned(TObjBlock(fCurrent^).Obj) and
    fSourceList.fFreeOnClear then
  begin
    OwnerCAD := TObjBlock(fCurrent^).Obj.OwnerCAD;
    TObjBlock(fCurrent^).Obj.Free;
  end;
  Obj.fOwnerCAD := OwnerCAD;
  TObjBlock(fCurrent^).Obj := Obj;
end;


// =====================================================================
// TIndexedObjectList
// =====================================================================

type
  TIdxObjListArray = array[0..0] of TObject;
  PIdxObjListArray = ^TIdxObjListArray;

procedure TIndexedObjectList.SetListSize(N: Integer);
var
  Cont: Integer;
begin
  if N <> fNumOfObject then
  begin
    if fFreeOnClear then
      for Cont := N to fNumOfObject - 1 do
        GetObject(Cont).Free;
    ReAllocMem(fListMemory, N * SizeOf(TObject));
    for Cont := fNumOfObject to N - 1 do
      TIdxObjListArray(fListMemory^)[Cont] := nil;
    if N = 0 then
      fListMemory := nil;
    fNumOfObject := N;
  end;
end;

procedure TIndexedObjectList.SetObject(IDX: Integer; Obj:
  TObject);
begin
  if not Assigned(fListMemory) then
    Exit;
  if IDX < fNumOfObject then
    TIdxObjListArray(fListMemory^)[IDX] := Obj
  else
    raise
      Exception.Create('TIndexedObjectList.SetObject: Index out of bounds.');
end;

function TIndexedObjectList.GetObject(IDX: Integer): TObject;
begin
  Result := nil;
  if not Assigned(fListMemory) then
    Exit;
  if IDX < fNumOfObject then
    Result := TIdxObjListArray(fListMemory^)[IDX]
  else
    raise
      Exception.Create('TIndexedObjectList.GetObject: Index out of bounds.');
end;

constructor TIndexedObjectList.Create(const Size: Integer);
begin
  inherited Create;

  fFreeOnClear := True;
  SetListSize(Size);
end;

destructor TIndexedObjectList.Destroy;
begin
  Clear;
  FreeMem(fListMemory, fNumOfObject * SizeOf(TObject));
  inherited;
end;

procedure TIndexedObjectList.Clear;
var
  Cont: Integer;
begin
  if fFreeOnClear then
    for Cont := 0 to fNumOfObject - 1 do
    begin
      GetObject(Cont).Free;
      SetObject(Cont, nil);
    end;
end;

// =====================================================================
// TPaintingThread
// =====================================================================

constructor TPaintingThread.Create(const Owner: TCADViewport;
  const ARect: TRect2D);
begin
  inherited Create(True); // Sempre disattivo alla partenza.

  FreeOnTerminate := True;
  fOwner := Owner;
  fRect := ARect;
end;

destructor TPaintingThread.Destroy;
begin
  DoTerminate;
  inherited;
end;

procedure TPaintingThread.Execute;
var
  Tmp: TGraphicObject;
  TmpIter: TGraphicObjIterator;
  Cont: Integer;
  TmpCanvas: TCanvas;
  TmpClipRect: TRect2D;
begin
  if not Assigned(fOwner) then
    Exit;
  with fOwner do
  try
    TmpCanvas := OffScreenCanvas.Canvas;
    TmpClipRect := RectToRect2D(ClientRect);
    TmpCanvas.Lock;
    try
      if fShowGrid and not fGridOnTop then
        DrawGrid(fRect, TmpCanvas);
      if (fViewportObjects <> nil) then
        TmpIter := fViewportObjects.GetIterator
      else if not Assigned(fDrawing) or fDrawing.IsBlocked then
        Exit
      else
        TmpIter := fDrawing.GetListOfObjects;
      try
        Tmp := TmpIter.First;
        if fDrawMode = DRAWMODE_NODRAW then
          Exit;
        Cont := 0;
        if fCopingFrequency > 0 then
          while Tmp <> nil do
          begin
            DrawObject(Tmp, OffScreenCanvas, TmpClipRect);
            Inc(Cont);
            if Cont >= fCopingFrequency then
            begin
              Synchronize(DoCopyCanvasThreadSafe);
              Cont := 0;
            end;
            Tmp := TmpIter.Next;
            if Terminated then
              Break;
          end
        else
          while Tmp <> nil do
          begin
            DrawObject(Tmp, OffScreenCanvas, TmpClipRect);
            Tmp := TmpIter.Next;
            if Terminated then
              Break;
          end;
      finally
        TmpIter.Free;
      end;
      if fShowGrid and fGridOnTop then
        DrawGrid(fRect, TmpCanvas);
    finally
      TmpCanvas.Unlock;
    end;
  except
  end;
  Synchronize(fOwner.DoCopyCanvasThreadSafe);
end;

// =====================================================================
// TLayer
// =====================================================================

procedure TLayer.Changed(Sender: TObject);
begin
  fModified := True;
end;

procedure TLayer.SetName(NM: TLayerName);
begin
  if fName <> NM then
  begin
    fName := NM;
    fModified := True;
  end;
end;

procedure TLayer.SetPen(Pn: TPen);
begin
  if Assigned(Pn) then
  begin
    fPen.Assign(Pn);
    fModified := True;
  end;
end;

procedure TLayer.SetBrush(BR: TBrush);
begin
  if Assigned(BR) then
  begin
    fBrush.Assign(BR);
    fModified := True;
  end;
end;

constructor TLayer.Create(IDX: Byte);
begin
  inherited Create;
  fIdx := IDX;
  fName := Format('Layer %d', [IDX]);
  fPen := TPen.Create;
  fPen.Color := clBlack;
  fPen.Style := psSolid;
  fBrush := TBrush.Create;
  //TSY:
  fBrush.Color := clSilver;
  //fBrush.Color := clGray;
  fBrush.Style := bsSolid;
  fDecorativePen := TDecorativePen.Create;
  fActive := True;
  fVisible := True;
  fOpaque := False;
  fStreamable := True;
  fModified := False;
  fPen.OnChange := Changed;
  fBrush.OnChange := Changed;
  fTag := 0;
end;

destructor TLayer.Destroy;
begin
  fPen.Free;
  fBrush.Free;
  fDecorativePen.Free;
  inherited Destroy;
end;

procedure TLayer.SaveToStream(const Stream: TStream);
var
  TmpColor: TColor;
  TmpPenStyle: TPenStyle;
  TmpPenMode: TPenMode;
  TmpWidth: Integer;
  TmpBrushStyle: TBrushStyle;
  TmpBool: Boolean;
begin
  TmpColor := fPen.Color;
  Stream.Write(TmpColor, SizeOf(TmpColor));
  TmpPenStyle := fPen.Style;
  Stream.Write(TmpPenStyle, SizeOf(TmpPenStyle));
  TmpPenMode := fPen.Mode;
  Stream.Write(TmpPenMode, SizeOf(TmpPenMode));
  TmpWidth := fPen.Width;
  Stream.Write(TmpWidth, SizeOf(TmpWidth));

  TmpColor := fBrush.Color;
  Stream.Write(TmpColor, SizeOf(TmpColor));
  TmpBrushStyle := fBrush.Style;
  Stream.Write(TmpBrushStyle, SizeOf(TmpBrushStyle));

  TmpWidth := fDecorativePen.PatternLenght;
  Stream.Write(TmpWidth, SizeOf(TmpWidth));
  for TmpWidth := 0 to fDecorativePen.PatternLenght - 1 do
  begin
    TmpBool := fDecorativePen.PenStyle[TmpWidth];
    Stream.Write(TmpBool, SizeOf(TmpBool));
  end;

  Stream.Write(fActive, SizeOf(Boolean));
  Stream.Write(fVisible, SizeOf(Boolean));
  Stream.Write(fOpaque, SizeOf(Boolean));
  Stream.Write(fStreamable, SizeOf(Boolean));
  Stream.Write(fName, SizeOf(TLayerName));
end;

procedure TLayer.LoadFromStream(const Stream: TStream;
  const Version: TCADVersion);
var
  TmpColor: TColor;
  TmpPenStyle: TPenStyle;
  TmpPenMode: TPenMode;
  TmpCont, TmpWidth: Integer;
  TmpBrushStyle: TBrushStyle;
  TmpBool: Boolean;
begin
  Stream.Read(TmpColor, SizeOf(TmpColor));
  fPen.Color := TmpColor;
  Stream.Read(TmpPenStyle, SizeOf(TmpPenStyle));
  fPen.Style := TmpPenStyle;
  Stream.Read(TmpPenMode, SizeOf(TmpPenMode));
  fPen.Mode := TmpPenMode;
  Stream.Read(TmpWidth, SizeOf(TmpWidth));
  fPen.Width := TmpWidth;

  Stream.Read(TmpColor, SizeOf(TmpColor));
  fBrush.Color := TmpColor;
  Stream.Read(TmpBrushStyle, SizeOf(TmpBrushStyle));
  fBrush.Style := TmpBrushStyle;
  if (Version < 'CAD422') then
    Stream.Read(TmpColor, SizeOf(TmpColor));

  if (Version >= 'CAD41') then
  begin
    Stream.Read(TmpWidth, SizeOf(TmpWidth));
    for TmpCont := 0 to TmpWidth - 1 do
    begin
      Stream.Read(TmpBool, SizeOf(TmpBool));
      fDecorativePen.PenStyle[TmpCont] := TmpBool;
    end;
  end;

  Stream.Read(fActive, SizeOf(Boolean));
  if (Version >= 'CAD4') then
    Stream.Read(fVisible, SizeOf(Boolean))
  else
    fVisible := True;
  Stream.Read(fOpaque, SizeOf(Boolean));
  if (Version = 'CAD3  ') then
  begin
    Stream.Read(fStreamable, SizeOf(Boolean));
    fName := Format('Layer %d', [fIdx]);
  end
  else if Version >= 'CAD33' then
  begin
    Stream.Read(fStreamable, SizeOf(Boolean));
    Stream.Read(fName, SizeOf(TLayerName));
  end
  else
  begin
    fStreamable := True;
    fName := Format('Layer %d', [fIdx]);
  end;
  fModified := True;
end;

function TLayer.SetCanvas(const Cnv: TDecorativeCanvas):
  Boolean;
begin
  Result := fVisible;
  if not fVisible then
    Exit;
  with Cnv do
  begin
    Canvas.Pen.Assign(Pen);
    Canvas.Brush.Assign(Brush);
    Canvas.Font.Color := Pen.Color;
    SetBkMode(Canvas, fOpaque);
  end;
  Cnv.DecorativePen.Assign(fDecorativePen);
end;

function TLayers.GetLayerByName(const NM: TLayerName): TLayer;
var
  Cont: Integer;
begin
  Result := nil;
  for Cont := 0 to 255 do
    if NM = TLayer(fLayers.Items[Cont]).fName then
      Result := TLayer(fLayers.Items[Cont]);
end;

function TLayers.GetLayer(Index: Byte): TLayer;
begin
  Result := TLayer(fLayers.Items[Index]);
end;

constructor TLayers.Create;
var
  Cont: Byte;
  TmpLay: TLayer;
begin
  inherited Create;
  fLayers := TList.Create;
  for Cont := 0 to 255 do
  begin
    TmpLay := TLayer.Create(Cont);
    TmpLay.fName := Format('Layer %d', [Cont]);
    fLayers.Add(TmpLay);
  end;
end;

destructor TLayers.Destroy;
begin
  while fLayers.Count > 0 do
  begin
    TLayer(fLayers.Items[0]).Free;
    fLayers.Delete(0);
  end;
  fLayers.Free;
  inherited Destroy;
end;

procedure TLayers.SaveToStream(const Stream: TStream);
var
  Cont: Word;
begin
  Cont := 1;
  Stream.Write(Cont, SizeOf(Cont));
  for Cont := 0 to 255 do
    with Stream do
      if TLayer(fLayers[Cont]).fModified then
      begin
        Write(Cont, SizeOf(Cont));
        TLayer(fLayers[Cont]).SaveToStream(Stream);
      end;
  Cont := 256;
  Stream.Write(Cont, SizeOf(Cont));
end;

procedure TLayers.LoadFromStream(const Stream: TStream;
  const Version: TCADVersion);
var
  Cont: Word;
begin
  Stream.Read(Cont, SizeOf(Cont));
  if Cont <> 1 then raise
    ECADFileNotValid.Create('TLayers.LoadFromStream: No layers found');
  while Stream.Position < Stream.Size do
    with Stream do
    begin
      Read(Cont, SizeOf(Cont));
      if Cont = 256 then Break;
      TLayer(fLayers[Cont]).LoadFromStream(Stream, Version);
    end;
end;

function TLayers.SetCanvas(const Cnv: TDecorativeCanvas;
  const Index: Byte): Boolean;
begin
  Result := TLayer(fLayers.Items[Index]).SetCanvas(Cnv);
end;

// =====================================================================
// TDrawing
// =====================================================================

function TDrawing.GetObjectsCount: Integer;
begin
  Result := fListOfObjects.Count;
end;

function TDrawing.GetSourceBlocksCount: Integer;
begin
  Result := fListOfBlocks.Count;
end;

function TDrawing.GetListOfObjects: TGraphicObjIterator;
begin
  Result := fListOfObjects.GetIterator;
end;

function TDrawing.GetListOfBlocks: TGraphicObjIterator;
begin
  Result := fListOfBlocks.GetIterator;
end;

procedure TDrawing.SetListOfObjects(NL: TGraphicObjList);
begin
  if HasIterators then
    raise
      ECADSysException.Create('TDrawing.SetListOfObjects: Cannot change ObjectList when the current one has active iterators.');
  if Assigned(NL) then
  begin
    DeleteAllObjects;
    fListOfObjects.Free;
    fListOfObjects := NL;
  end;
end;

procedure TDrawing.SetListOfBlocks(NL: TGraphicObjList);
begin
  if HasIterators then
    raise
      ECADSysException.Create('TDrawing.SetListOfBlocks: Cannot change BlocksList when the current one has active iterators.');
  if Assigned(NL) then
  begin
    DeleteAllSourceBlocks;
    fListOfBlocks.Free;
    fListOfBlocks := NL;
  end;
end;

function TDrawing.GetExclusiveListOfObjects:
  TExclusiveGraphicObjIterator;
begin
  Result := fListOfObjects.GetExclusiveIterator;
end;

function TDrawing.GetExclusiveListOfBlocks:
  TExclusiveGraphicObjIterator;
begin
  Result := fListOfBlocks.GetExclusiveIterator;
end;

function TDrawing.GetIsBlocked: Boolean;
begin
  Result := fListOfObjects.HasExclusiveIterators or
    fListOfBlocks.HasExclusiveIterators;
end;

function TDrawing.GetHasIterators: Boolean;
begin
  Result := fListOfObjects.HasIterators or
    fListOfBlocks.HasIterators;
end;

function TDrawing.GetViewport(IDX: Integer): TCADViewport;
begin
  Result := TCADViewport(fListOfViewport[IDX]);
end;

function TDrawing.GetViewportsCount: Integer;
begin
  Result := fListOfViewport.Count;
end;

constructor TDrawing.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fListOfObjects := TGraphicObjList.Create;
  fListOfObjects.FreeOnClear := True;
  fListOfBlocks := TGraphicObjList.Create;
  fListOfBlocks.FreeOnClear := True;

  fListOfViewport := TList.Create;
  fLayers := TLayers.Create;
  fCurrentLayer := 0;
  fRepaintAfterTransform := True;
  fDrawOnAdd := False;
  fNextID := 0;
  fNextBlockID := 0;
  fVersion := CADSysVersion;
  fSelectedObjs := TGraphicObjList.Create;
  fSelectedObjs.FreeOnClear := False;
  fSelectionFilter := TObject2D;
end;

// Used because BlockList can contain circular references.

procedure TDrawing.DeleteAllSourceBlocks;
var
  TmpObj: TGraphicObject;
  Deleted: Integer;
  TmpIter: TExclusiveGraphicObjIterator;
  OnChangeDrawing0: TOnChangeDrawing;
begin
  TmpIter := fListOfBlocks.GetExclusiveIterator;
  OnChangeDrawing0 := fOnChangeDrawing;
  fOnChangeDrawing := nil;
  try
    repeat
      Deleted := 0;
      TmpObj := TmpIter.First;
      while Assigned(TmpObj) do
      begin
        try
          TmpIter.DeleteCurrent;
          Inc(Deleted);
          TmpObj := TmpIter.Current;
        except
          TmpObj := TmpIter.Next;
        end;
      end;
      if (Deleted = 0) and (fListOfBlocks.Count > 0) then
      begin
        raise
          ECADSourceBlockIsReferenced.Create('TDrawing.FreeSourceBlocks: CADSys 4.0 Severe error'#10#13'The drawing contains circular reference of source blocks. They will be not deleted !');
        Exit;
      end;
    until TmpIter.Count = 0;
  finally
    fOnChangeDrawing := OnChangeDrawing0;
    TmpIter.Free;
  end;
  NotifyChanged;
end;

procedure TDrawing.DeleteAllObjects;
var
  OnChangeDrawing0: TOnChangeDrawing;
begin
  SelectionClear;
  OnChangeDrawing0 := fOnChangeDrawing;
  fOnChangeDrawing := nil;
  try
    try
      fListOfObjects.Clear;
    except
    end;
  finally
    fOnChangeDrawing := OnChangeDrawing0;
  end;
  NotifyChanged;
  fNextID := 0;
end;

destructor TDrawing.Destroy;
var
  Cont: Integer;
begin
  fOnChangeDrawing := nil;
  DeleteAllObjects;
  fListOfObjects.Free;
  DeleteAllSourceBlocks;
  fListOfBlocks.Free;
  for Cont := 0 to fListOfViewport.Count - 1 do
    TCADViewport(fListOfViewport[Cont]).fDrawing := nil;
  fListOfViewport.Free;
  fLayers.Free;
  fSelectedObjs.Free;
  inherited Destroy;
end;

procedure TDrawing.SaveToStream(const Stream: TStream);
var
  TmpByte: Byte;
begin
  with Stream do
  begin
     { Write the signature for the version. }
    Write(fVersion, SizeOf(fVersion));
     { Save the layer informations. }
    fLayers.SaveToStream(Stream);
     { Save the source blocks. }
    TmpByte := 2;
    Write(TmpByte, SizeOf(TmpByte));
    SaveBlocksToStream(Stream, False);
     { Save the objects. }
    TmpByte := 3;
    Write(TmpByte, SizeOf(TmpByte));
    SaveObjectsToStream(Stream);
  end;
end;

procedure TDrawing.MergeFromStream(const Stream: TStream);
var
  TmpVersion: TCADVersion;
  TmpByte: Byte;
  TmpBool: Boolean;
begin
  with Stream do
  begin
    Read(TmpVersion, SizeOf(TmpVersion));
    TmpBool := TmpVersion = CADSysVersion;
    if (not TmpBool) and Assigned(fOnVerError) then
      fOnVerError(Self, stDrawing, Stream, TmpBool);
    if TmpBool then
    begin
        { Load the layer informations. }
      fLayers.LoadFromStream(Stream, TmpVersion);
        { Load the source blocks. }
      Read(TmpByte, SizeOf(TmpByte));
      if TmpByte <> 2 then
        raise
          ECADFileNotValid.Create('TDrawing.MergeFromStream: no blocks found');
      LoadBlocksFromStream(Stream, TmpVersion);
        { Load the objects. }
      Read(TmpByte, SizeOf(TmpByte));
      if TmpByte <> 3 then
        raise
          ECADFileNotValid.Create('TDrawing.MergeFromStream: no objects found');
      LoadObjectsFromStream(Stream, TmpVersion);
    end
    else
      raise
        ECADFileNotValid.Create('TDrawing.MergeFromStream: Invalid stream version.');
  end;
end;

procedure TDrawing.LoadFromStream(const Stream: TStream);
begin
  { Delete all objects. }
  DeleteAllObjects;
  DeleteSavedSourceBlocks;
  MergeFromStream(Stream);
end;

procedure TDrawing.LoadLibrary(const Stream: TStream);
var
  TmpVersion: TCADVersion;
  TmpByte: Byte;
  TmpBool: Boolean;
begin
  with Stream do
  begin
    Read(TmpVersion, SizeOf(TmpVersion));
    TmpBool := TmpVersion = CADSysVersion;
    if (not TmpBool) and Assigned(fOnVerError) then
      fOnVerError(Self, stLibrary, Stream, TmpBool);
    if TmpBool then
    begin
        { Load the source blocks. }
      Read(TmpByte, SizeOf(TmpByte));
      if TmpByte <> 2 then
        raise
          ECADFileNotValid.Create('TDrawing.LoadLibrary: no blocks found');
      LoadBlocksFromStream(Stream, TmpVersion);
    end
    else
      raise
        ECADFileNotValid.Create('TDrawing.LoadLibrary: Invalid stream version.');
  end;
end;

procedure TDrawing.SaveLibrary(const Stream: TStream);
var
  TmpByte: Byte;
begin
  with Stream do
  begin
     { Write the signature for the version. }
    Write(fVersion, SizeOf(fVersion));
     { Save the source blocks. }
    TmpByte := 2;
    Write(TmpByte, SizeOf(TmpByte));
    SaveBlocksToStream(Stream, True);
  end;
end;

procedure TDrawing.MergeFromFile(const FileName: string);
var
  TmpStr: TFileStream;
begin
  TmpStr := TFileStream.Create(FileName, fmOpenRead);
  try
    MergeFromStream(TmpStr);
    RepaintViewports;
  finally
    TmpStr.Free;
  end;
end;

procedure TDrawing.LoadFromFile(const FileName: string);
var
  TmpStr: TFileStream;
begin
  TmpStr := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(TmpStr);
    RepaintViewports;
  finally
    TmpStr.Free;
  end;
end;

procedure TDrawing.SaveToFile(const FileName: string);
var
  TmpStr: TFileStream;
begin
  TmpStr := TFileStream.Create(FileName, fmOpenWrite or
    fmCreate);
  try
    SaveToStream(TmpStr);
  finally
    TmpStr.Free;
  end;
end;

function TDrawing.SaveToFile_EMF(const FileName: string): Boolean;
var
  MetaFile: TMetaFile;
begin
  //StopRepaint;
  MetaFile := Self.Viewports[0].AsMetafile;
  Result := False;
  try
    MetaFile.SaveToFile(FileName);
  finally
    MetaFile.Free;
    Result := FileExists(FileName);
  end;
end;

procedure EMFtoPNG(const EMF: TMetaFile;
  const Resolution: Integer; const FileName: string);
var
  aBitmap: TBitmap;
  aPNG: TPNGObject;
begin
  aBitmap := TBitmap.Create;
  aBitmap.Width := MulDiv(EMF.MMWidth, Resolution, 2540);
  aBitmap.Height := MulDiv(EMF.MMHeight, Resolution, 2540);
  aBitmap.Canvas.StretchDraw(Rect(0, 0,
    aBitmap.Width, aBitmap.Height), EMF);
  //aBitmap.Canvas.Draw(0, 0, EMF);
  aPNG := TPNGObject.Create;
  try
    aPNG.Assign(aBitmap);
    aPNG.SaveToFile(ChangeFileExt(FileName, '.png'));
  finally
    aPNG.Free;
    aBitmap.Free;
  end;
end;

procedure BitmapToPNG(const aBitmap: TBitmap;
  const FileName: string);
var
  aPNG: TPNGObject;
begin
  aPNG := TPNGObject.Create;
  try
    aPNG.Assign(aBitmap);
    aPNG.SaveToFile(ChangeFileExt(FileName, '.png'));
  finally
    aPNG.Free;
  end;
end;

procedure TDrawing.SaveToFile_Bitmap(const FileName: string);
var
  Bitmap: TBitmap;
begin
  //StopRepaint;
  Bitmap := Self.Viewports[0].AsBitmap;
  try
    Bitmap.SaveToFile(FileName);
  finally
    Bitmap.Free;
  end;
end;

procedure TDrawing.SaveToFile_PNG(const FileName: string);
var
  Bitmap: TBitmap;
begin
  //StopRepaint;
  Bitmap := Self.Viewports[0].AsBitmap;
  try
    BitmapToPNG(Bitmap, FileName);
  finally
    Bitmap.Free;
  end;
end;

function TDrawing.AddSourceBlock(ID: Integer; const Obj:
  TGraphicObject): TGraphicObject;
begin
  Result := Obj;
  if ID < 0 then
  begin
    ID := fNextBlockID;
    Inc(fNextBlockID);
  end
  else
    if ID >= fNextBlockID then fNextBlockID := ID + 1;
  Obj.fOwnerCAD := Self;
  Obj.Layer := fCurrentLayer;
  Obj.ID := ID;
  Obj.UpdateExtension(Self);
  fListOfBlocks.Add(Obj);
end;

function TDrawing.GetSourceBlock(ID: Integer): TGraphicObject;
var
  TmpIter: TGraphicObjIterator;
begin
  TmpIter := GetListOfBlocks;
  try
    Result := TmpIter.Search(ID);
  finally
    TmpIter.Free;
  end;
end;

function TDrawing.FindSourceBlock(const SrcName:
  TSourceBlockName): TGraphicObject;
begin
  Result := nil;
end;

procedure TDrawing.DeleteSourceBlockByID(const ID: Integer);
var
  TmpObj: TGraphicObject;
begin
  TmpObj := GetSourceBlock(ID);
  if TmpObj = nil then
    raise
      ECADListObjNotFound.Create('TDrawing.DeleteSourceBlock: No source block found');
  try
    fListOfBlocks.Delete(ID);
  except
  end;
end;

function TDrawing.AddObject(ID: Integer; const Obj:
  TGraphicObject): TGraphicObject;
begin
  Result := Obj;
  if ID < 0 then
  begin
    ID := fNextID;
    Inc(fNextID);
  end
  else
    if ID >= fNextID then fNextID := ID + 1;
  Obj.fOwnerCAD := Self;
  Obj.Layer := fCurrentLayer;
  Obj.ID := ID;
  Obj.UpdateExtension(Self);
  fListOfObjects.Add(Obj);
  if fDrawOnAdd then
    RedrawObject(Obj);
  if Assigned(fOnAddObject) then
    fOnAddObject(Self, Obj);
  NotifyChanged;
end;

procedure TDrawing.AddList(const Lst: TGraphicObjList);
var
//  ID: Integer;
  Obj: TGraphicObject;
  Iter: TGraphicObjIterator;
  OnChangeDrawing0: TOnChangeDrawing;
  I: Integer;
begin
  OnChangeDrawing0 := fOnChangeDrawing;
  fOnChangeDrawing := nil;
  try
    fListOfObjects.AddFromList(Lst);
    Iter := Lst.GetIterator;
    I := 0;
    try
      Obj := Iter.First;
      while Assigned(Obj) do
      begin
        Obj.fOwnerCAD := Self;
        Obj.Layer := fCurrentLayer;
        Obj.ID := fNextID;
        Inc(fNextID);
        Obj.UpdateExtension(Self);
        if fDrawOnAdd then
          RedrawObject(Obj);
        if Assigned(fOnAddObject) then
          fOnAddObject(Self, Obj);
        Inc(I);
        if I mod 100 = 0 then ShowProgress(I / Lst.Count);
        Obj := Iter.Next;
      end;
    finally
      Iter.Free;
    end;
  finally
    fOnChangeDrawing := OnChangeDrawing0;
  end;
  NotifyChanged;
end;

function TDrawing.InsertObject(ID, IDInsertPoint: Integer; const
  Obj: TGraphicObject): TGraphicObject;
begin
  Result := Obj;
  fListOfObjects.Insert(IDInsertPoint, Obj);
  if ID < 0 then
  begin
    ID := fNextID;
    Inc(fNextID);
  end
  else
    if ID > fNextID then fNextID := ID;
  Obj.fOwnerCAD := Self;
  Obj.Layer := fCurrentLayer;
  Obj.ID := ID;
  Obj.UpdateExtension(Self);
  if fDrawOnAdd then
    RedrawObject(Obj);
  if Assigned(fOnAddObject) then
    fOnAddObject(Self, Obj);
  NotifyChanged;
end;

procedure TDrawing.MoveObject(const IDOrigin, IDDestination:
  Integer);
begin
  fListOfObjects.Move(IDOrigin, IDDestination);
  NotifyChanged;
end;

procedure TDrawing.RemoveObject(const ID: Integer);
var
  TmpObj: TGraphicObject;
begin
  TmpObj := GetObject(ID);
  if TmpObj = nil then
    raise
      ECADListObjNotFound.Create('TDrawing.RemoveObject: No object found');
  TmpObj.fOwnerCAD := nil;
  fListOfObjects.Remove(ID);
  NotifyChanged;
end;

procedure TDrawing.DeleteObject(const ID: Integer);
var
  TmpObj: TGraphicObject;
begin
  TmpObj := GetObject(ID);
  if TmpObj = nil then
    raise
      ECADListObjNotFound.Create('TDrawing.DeleteObject: No object found');
  fListOfObjects.Delete(ID);
  NotifyChanged;
end;

procedure TDrawing.ChangeObjectLayer(const ID: Integer; const
  NewLayer: Byte);
var
  TmpObj: TGraphicObject;
begin
  TmpObj := GetObject(ID);
  if TmpObj = nil then
    raise
      ECADListObjNotFound.Create('TDrawing.ChangeObjectLayer: No object found');
  TmpObj.Layer := NewLayer;
end;

function TDrawing.GetObject(ID: Integer): TGraphicObject;
var
  TmpIter: TGraphicObjIterator;
begin
  TmpIter := GetListOfObjects;
  try
    Result := TmpIter.Search(ID);
  finally
    TmpIter.Free;
  end;
end;

procedure TDrawing.AddViewports(const VP: TCADViewport);
begin
  if not Assigned(VP) then Exit;
  fListOfViewport.Add(VP);
end;

procedure TDrawing.DelViewports(const VP: TCADViewport);
var
  Cont: Integer;
begin
  if not Assigned(VP) then Exit;
  Cont := fListOfViewport.IndexOf(VP);
  if Cont >= 0 then fListOfViewport.Delete(Cont);
end;

procedure TDrawing.RepaintViewports;
var
  Cont: Integer;
begin
  for Cont := 0 to fListOfViewport.Count - 1 do
    TCADViewport(fListOfViewport.Items[Cont]).Repaint;
end;

procedure TDrawing.RefreshViewports;
var
  Cont: Integer;
begin
  for Cont := 0 to fListOfViewport.Count - 1 do
    TCADViewport(fListOfViewport.Items[Cont]).Refresh;
end;

procedure TDrawing.RedrawObject(const Obj: TGraphicObject);
var
  Cont: Integer;
begin
  for Cont := 0 to fListOfViewport.Count - 1 do
    with TCADViewport(fListOfViewport.Items[Cont]) do
    begin
      DrawObject(Obj, OffScreenCanvas,
        RectToRect2D(ClientRect));
      Refresh;
    end;
end;

procedure TDrawing.SetDefaultBrush(const Brush: TBrush);
var
  Cont: Byte;
begin
  for Cont := 0 to 255 do
    if not fLayers[Cont].Modified then
    begin
      fLayers[Cont].Brush.Assign(Brush);
      fLayers[Cont].fModified := False;
    end;
end;

procedure TDrawing.SetDefaultPen(const Pen: TPen);
var
  Cont: Byte;
begin
  for Cont := 0 to 255 do
    if not fLayers[Cont].Modified then
    begin
      fLayers[Cont].Pen.Assign(Pen);
      fLayers[Cont].fModified := False;
    end;
end;

procedure TDrawing.SetDefaultLayersColor(const C: TColor);
var
  Cont: Byte;
begin
  for Cont := 0 to 255 do
    if not fLayers[Cont].Modified then
    begin
      fLayers[Cont].Pen.Color := C;
      fLayers[Cont].fModified := False;
    end;
end;

function TDrawing.GetDefaultLayersColor: TColor;
begin
  Result := fLayers[0].Pen.Color;
end;

procedure TDrawing.SelectionClear;
var
  Iter: TGraphicObjIterator;
  Current: TGraphicObject;
begin
  Iter := fSelectedObjs.GetIterator;
  try
    Current := Iter.First;
    while Assigned(Current) do
    begin
      if Current is TObject2D then
        (Current as TObject2D).HasControlPoints := False;
      Current := Iter.Next;
    end;
  finally
    Iter.Free;
  end;
  fSelectedObjs.Clear;
end;

procedure TDrawing.SelectionAdd(const Obj:
  TGraphicObject);
begin
  if Obj is TObject2D then
    (Obj as TObject2D).HasControlPoints := True;
  fSelectedObjs.Add(Obj);
    {IgnoreEvents := True;
    try
      if Assigned(fOnSelected) then
        fOnSelected(TCAD2DSelectObjectsParam(Param),
          Obj, fLastSelectedCtrlPoint, True);
    finally
      IgnoreEvents := False;
    end;}
end;

procedure TDrawing.SelectionAddList(const List:
  TGraphicObjList);
var
  ExIter: TExclusiveGraphicObjIterator;
  Current: TGraphicObject;
begin
  ExIter := List.GetExclusiveIterator;
  try
    Current := ExIter.First;
    while Assigned(Current) do
    begin
      if fSelectedObjs.Find(Current.ID) = nil then
      begin
        fSelectedObjs.Add(Current);
        if Current is TObject2D then
          (Current as TObject2D).HasControlPoints := True;
      end;
      Current := ExIter.Next;
    end;
  finally
    ExIter.Free;
  end;
end;

function TDrawing.SelectionRemove(const Obj:
  TGraphicObject): Boolean;
var
  ExIter: TExclusiveGraphicObjIterator;
begin
  Result := False;
  if not Assigned(Obj) then Exit;
  ExIter := fSelectedObjs.GetExclusiveIterator;
  try
    if ExIter.Search(Obj.ID) <> nil then
    begin
      if Obj is TObject2D then
        (Obj as TObject2D).HasControlPoints := False;
      ExIter.RemoveCurrent;
      Result := True;
    end;
  finally
    ExIter.Free;
  end;
end;

procedure TDrawing.SelectAll;
var
  ExIter: TExclusiveGraphicObjIterator;
  Current: TGraphicObject;
begin
  SelectionClear;
  ExIter := Self.GetExclusiveListOfObjects;
  try
    Current := ExIter.First;
    while Assigned(Current) do
    begin
      fSelectedObjs.Add(Current);
      if Current is TObject2D then
        (Current as TObject2D).HasControlPoints := True;
      Current := ExIter.Next;
    end;
  finally
    ExIter.Free;
  end;
end;

procedure TDrawing.SelectNext(Direction: Integer);
var
  TmpIter: TGraphicObjIterator;
  TmpIter2: TGraphicObjIterator;
  Current: TGraphicObject;
begin
  TmpIter := fSelectedObjs.GetIterator;
  TmpIter2 := ObjectsIterator;
  try
    if Direction > 0 then
      Current := TmpIter.Last
    else
      Current := TmpIter.First;
    if Current = nil then
      Current := TmpIter2.First
    else
    begin
      TmpIter2.Search(Current.ID);
      if Direction > 0 then
      begin
        Current := TmpIter2.Next;
        if Current = nil then
          Current := TmpIter2.First;
      end
      else
      begin
        Current := TmpIter2.Prev;
        if Current = nil then
          Current := TmpIter2.Last;
      end
    end;
  finally
    TmpIter2.Free;
    TmpIter.Free;
  end;
  if Assigned(Current) then
  begin
    SelectionClear;
    SelectionAdd(Current);
  end;
end;

procedure TDrawing.DeleteSelected;
var
  ExIter: TExclusiveGraphicObjIterator;
  Current: TGraphicObject;
  OnChangeDrawing0: TOnChangeDrawing;
begin
  ExIter := fSelectedObjs.GetExclusiveIterator;
  try
    Current := ExIter.First;
    OnChangeDrawing0 := fOnChangeDrawing;
    fOnChangeDrawing := nil;
    try
      while Assigned(Current) do
      begin
        DeleteObject(Current.ID);
        Current := ExIter.Next;
      end;
    finally
      fOnChangeDrawing := OnChangeDrawing0;
    end;
  finally
    ExIter.Free;
  end;
  fSelectedObjs.Clear;
  NotifyChanged;
end;

function TDrawing.GetSelectionExtension: TRect2D;
var
  TmpIter: TGraphicObjIterator;
begin
  if not (Self is TDrawing2D)
    or (fSelectedObjs.Count = 0) then
  begin
    if ViewportsCount > 0 then
      Result := Viewports[0].VisualRect
      {TransformRect2D(Viewports[0].VisualRect,
        Viewports[0].ViewportToScreenTransform)}
    else Result := Rect2D(0, 0, 0, 0);
    Exit;
  end;
  TmpIter := fSelectedObjs.GetIterator;
  try
    Result := GetExtension0(Self as TDrawing2D, TmpIter);
  finally
    TmpIter.Free;
  end;
end;

function TDrawing.GetSelectionCenter: TPoint2D;
var
  E: TRect2D;
begin
  E := GetSelectionExtension;
  Result := MidPoint(E.FirstEdge, E.SecondEdge);
end;

procedure TDrawing.ChangeSelected(ChangeProc: TChangeProc; PData: Pointer);
var
  Obj: TGraphicObject;
  Iter: TGraphicObjIterator;
begin
  Iter := SelectedObjects.GetIterator;
  try
    Obj := Iter.First;
    while Assigned(Obj) do
    begin
      ChangeProc(Obj, PData);
      Obj.UpdateExtension(Self);
      Obj := Iter.Next;
    end;
  finally
    Iter.Free;
  end;
  RepaintViewports;
  NotifyChanged;
end;

procedure TDrawing.ChangeLineKind(const Obj: TGraphicObject; PData: Pointer);
begin
  if Obj is TPrimitive2D then
    (Obj as TPrimitive2D).LineStyle := TLineStyle(PData^);
end;

procedure TDrawing.ChangeLineColor(const Obj: TGraphicObject; PData: Pointer);
begin
  if Obj is TPrimitive2D then
    (Obj as TPrimitive2D).LineColor := TColor(PData^);
end;

procedure TDrawing.ChangeHatching(const Obj: TGraphicObject; PData: Pointer);
begin
  if Obj is TPrimitive2D then
    (Obj as TPrimitive2D).Hatching := THatching(PData^);
end;


procedure TDrawing.ChangeHatchColor(const Obj: TGraphicObject; PData: Pointer);
begin
  if Obj is TPrimitive2D then
    (Obj as TPrimitive2D).HatchColor := TColor(PData^);
end;

procedure TDrawing.ChangeFillColor(const Obj: TGraphicObject; PData: Pointer);
begin
  if Obj is TPrimitive2D then
    (Obj as TPrimitive2D).FillColor := TColor(PData^);
end;

procedure TDrawing.ChangeLineWidth(const Obj: TGraphicObject; PData: Pointer);
begin
  if Obj is TPrimitive2D then
    (Obj as TPrimitive2D).LineWidth := TRealType(PData^);
end;

procedure TDrawing.NotifyChanged;
begin
  if Assigned(fOnChangeDrawing) then
    fOnChangeDrawing(Self);
end;

// =====================================================================
// TCADViewport
// =====================================================================

procedure TCADViewport.CopyBitmapOnCanvas(const DestCnv:
  TCanvas; const BMP: TBitmap; IRect: TRect; IsTransparent:
  Boolean; TransparentColor: TColor);
begin
  if (IsTransparent and
    not (csDesigning in ComponentState)) then
  begin
    DestCnv.Brush.Style := bsClear;
    DestCnv.BrushCopy(IRect, BMP, IRect, TransparentColor);
  end
  else
    DestCnv.CopyRect(IRect, BMP.Canvas, IRect);
end;

procedure TCADViewport.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params.WindowClass do
  begin
    Style := Style and not ({CS_HREDRAW} DWORD(2) or {CS_VREDRAW}  DWORD(1));
    if fTransparent and not (csDesigning in ComponentState) then
    begin
      Style := Style and not {WS_CLIPCHILDREN}  $2000000;
      Style := Style and not {WS_CLIPSIBLINGS}  $4000000;
      Params.ExStyle := Params.ExStyle or {WS_EX_TRANSPARENT}  $20;
    end;
  end;
end;

function TCADViewport.CreateOffScreenCanvas(const Cnv: TCanvas):
  TDecorativeCanvas;
begin
  Result := TDecorativeCanvas.Create(Cnv);
end;

procedure TCADViewport.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  if (not Assigned(fOnClear)) and
    (not fTransparent) or
    (csDesigning in ComponentState) then
    inherited
  else
    Message.Result := 1;
end;

procedure TCADViewport.WMSize(var Message: TWMSize);
begin
  inherited;
  DoResize;
end;

procedure TCADViewport.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Assigned(fOnMouseEnter) then
    fOnMouseEnter(Self);
end;

procedure TCADViewport.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Assigned(fOnMouseLeave) then
    fOnMouseLeave(Self);
end;

procedure TCADViewport.SetDeltaX(const V: TRealType);
begin
  if fGridDeltaX <> V then
  begin
    StopRepaint;
    fGridDeltaX := V;
    Repaint;
  end;
end;

procedure TCADViewport.SetDeltaY(const V: TRealType);
begin
  if fGridDeltaY <> V then
  begin
    StopRepaint;
    fGridDeltaY := V;
    Repaint;
  end;
end;

procedure TCADViewport.SetSubX(const V: TRealType);
begin
  if fGridSubX <> V then
  begin
    StopRepaint;
    fGridSubX := V;
    Repaint;
  end;
end;

procedure TCADViewport.SetSubY(const V: TRealType);
begin
  if fGridSubY <> V then
  begin
    StopRepaint;
    fGridSubY := V;
    Repaint;
  end;
end;

procedure TCADViewport.SetBackColor(const Cl: TColor);
begin
  if fBackGroundColor <> Cl then
  begin
    StopRepaint;
    fBackGroundColor := Cl;
    fRubberPen.Color := fRubberPenColor xor Cl;
    Repaint;
  end;
end;

procedure TCADViewport.SetTransparent(const B: Boolean);
begin
  if (fTransparent <> B) then
  begin
    StopRepaint;
    fTransparent := B;
    Repaint;
  end;
end;

procedure TCADViewport.SetOnClearCanvas(const H: TClearCanvas);
begin
  StopRepaint;
  fOnClear := H;
  Repaint;
end;

procedure TCADViewport.SetShowGrid(const B: Boolean);
begin
  if fShowGrid <> B then
  begin
    StopRepaint;
    fShowGrid := B;
    Repaint;
  end;
end;

procedure TCADViewport.SetGridColor(const Cl: TColor);
begin
  if fGridColor <> Cl then
  begin
    StopRepaint;
    fGridColor := Cl;
    Repaint;
  end;
end;

procedure TCADViewport.SetDrawing(Cad: TDrawing);
begin
  if Cad <> fDrawing then
  begin
    StopRepaint;
    if Assigned(Cad) and not (csDesigning in ComponentState)
      then
    begin
      if Assigned(fDrawing) then
        fDrawing.DelViewports(Self);
      Cad.AddViewports(Self);
    end;
    fDrawing := Cad;
  end;
end;

procedure TCADViewport.ClearCanvas(Sender: TObject; Cnv:
  TCanvas; const ARect: TRect2D; const BackCol: TColor);
begin
  with Cnv do
  begin
    Brush.Color := BackCol;
    Brush.Style := bsSolid;
    with TransformRect2D(ARect, fViewportToScreen) do
      FillRect(Rect(Round(Left), Round(Top), Round(Right) + 1,
        Round(Bottom) + 1));
  end;
end;

procedure TCADViewport.DoCopyCanvas(const GenEvent: Boolean);
begin
  CopyBackBufferRectOnCanvas(Rect(0, 0, Width, Height),
    GenEvent);
end;

procedure TCADViewport.DoCopyCanvasThreadSafe;
begin
  CopyBackBufferRectOnCanvas(Rect(0, 0, Width, Height), False);
end;

procedure TCADViewport.CopyBackBufferRectOnCanvas(const Rect:
  TRect; const GenEvent: Boolean);
begin
  if HandleAllocated then
  begin
    fOffScreenCanvas.Canvas.Lock;
    try
      CopyBitmapOnCanvas(Canvas, fOffScreenBitmap, Rect,
        fTransparent, fBackGroundColor);
    finally
      fOffScreenCanvas.Canvas.Unlock;
    end;
  end;
  if Assigned(fOnPaint) and GenEvent and (not fDisablePaintEvent)
    then
  try
    fDisablePaintEvent := True;
    fOnPaint(Self);
  finally
    fDisablePaintEvent := False;
  end;
end;

constructor TCADViewport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fViewGuard := TCADSysCriticalSection.Create;
  ControlStyle := ControlStyle - [csOpaque];
  ControlStyle := ControlStyle + [csClickEvents, csSetCaption,
    csDoubleClicks {TSY}];
  fPaintingThread := nil;
  CopingFrequency := 0;
  fDrawMode := DRAWMODE_NORMAL;
  Height := 50;
  Width := 50;
  fOnClear := nil;
  fBackGroundColor := clWhite;
  fGridColor := clMoneyGreen;
  fShowGrid := False;
  fTransparent := False;
  fInUpdate := False;
  fGridDeltaX := 0.0;
  fGridDeltaY := 0.0;
  fGridSubX := 0.0;
  fGridSubY := 0.0;
  fViewportObjects := nil;
  fDisableMouseEvents := False;
  fDrawing := nil;
  fShowControlPoints := False;
  fControlPointsWidth := 7;
  fVisualWindow := Rect2D(0.0, 0.0, 100.0, 100.0);
  fScreenToViewport := IdentityTransf2D;
  fViewportToScreen := IdentityTransf2D;
  fRubberPen := TPen.Create;
  fUseThread := False;
  with fRubberPen do
  begin
    //Mode := pmXOr;
    Mode := pmNot;
    Style := psDash;
    Width := 1;
  end;
  //SetRubberColor(clRed);
  SetRubberColor(clMaroon);
  fAspectRatio := 0.0;
  fGridOnTop := False;
  fOffScreenBitmap := TBitmap.Create;
  fOffScreenBitmap.Height := Height;
  fOffScreenBitmap.Width := Width;
  fOffScreenBitmap.PixelFormat := pf24bit;
  fOffScreenCanvas :=
    CreateOffScreenCanvas(fOffScreenBitmap.Canvas);
  fOnScreenCanvas := TDecorativeCanvas.Create(Canvas);
  //TSY: added
  fControlPointsColor := clWhite;
  ShowRulers := False;
end;

destructor TCADViewport.Destroy;
begin
  StopPaintingThread;
  fRubberPen.Free;
  if Assigned(fDrawing) then
    fDrawing.DelViewports(Self);
  fViewGuard.Free;
  fOffScreenCanvas.Free;
  fOnScreenCanvas.Free;
  fOffScreenCanvas := nil;
  fOnScreenCanvas := nil;
  fOffScreenBitmap.Free;
  fOffScreenBitmap := nil;
  inherited Destroy;
end;

procedure TCADViewport.BeginUpdate;
begin
  StopRepaint;
  fInUpdate := True;
end;

procedure TCADViewport.EndUpdate;
begin
  fInUpdate := False;
  Repaint;
end;

procedure TCADViewport.SetRubberColor(const Cl: TColor);
begin
  if Cl <> fRubberPenColor then
  begin
    StopRepaint;
    fRubberPenColor := Cl;
    fRubberPen.Color := Cl xor fBackGroundColor;
  end;
end;

procedure TCADViewport.Paint;
begin
  if fPaintingThread = nil then
    DoCopyCanvas(True);
end;

procedure TCADViewport.RefreshRect(const ARect: TRect);
var
  TmpRect: TRect;
begin
  if fPaintingThread <> nil then
    Exit;
  TmpRect := Rect(ARect.Left - 1, ARect.Top - 1, ARect.Right +
    1, ARect.Bottom + 1);
  CopyBackBufferRectOnCanvas(TmpRect, True);
end;

procedure TCADViewport.DoResize;
begin
  StopRepaint;
  fOffScreenBitmap.Height := Height;
  fOffScreenBitmap.Width := Width;
  ChangeViewportTransform(fVisualWindow);
  if Assigned(fOnResize) then
    fOnResize(Self);
end;

procedure TCADViewport.StopPaintingThread;
begin
  if Assigned(fPaintingThread) then
  try
    TPaintingThread(fPaintingThread).Terminate;
    if Assigned(fPaintingThread) then
      TPaintingThread(fPaintingThread).WaitFor;
    fPaintingThread := nil;
    if Assigned(fOnPaint) and (not fDisablePaintEvent) then
    try
      fDisablePaintEvent := True;
      fOnPaint(Self);
    finally
      fDisablePaintEvent := False;
    end;
  finally
    fPaintingThread := nil;
  end;
end;

procedure TCADViewport.OnThreadEnded(Sender: TObject);
begin
  fPaintingThread := nil;
  if Assigned(fOnPaint) and (not fDisablePaintEvent) then
  try
    fDisablePaintEvent := True;
    fOnPaint(Self);
  finally
    fDisablePaintEvent := False;
  end;
  if Assigned(fOnEndRedraw) then
    fOnEndRedraw(Self);
end;

procedure TCADViewport.UpdateViewport(const ARect: TRect2D);
var
  Tmp: TGraphicObject;
  TmpIter: TGraphicObjIterator;
  TmpCanvas: TCanvas;
  TmpClipRect: TRect2D;
  Cont: Integer;
begin
  if fInUpdate then
    Exit;
  StopRepaint;
  if Assigned(fOnClear) then
    fOnClear(Self, fOffScreenCanvas.Canvas, ARect,
      fBackGroundColor)
  else
    ClearCanvas(Self, fOffScreenCanvas.Canvas, ARect,
      fBackGroundColor);
  if Assigned(fOnBeginRedraw) then
    fOnBeginRedraw(Self);
  if fUseThread then
  begin
    fPaintingThread := TPaintingThread.Create(Self, ARect);
    TPaintingThread(fPaintingThread).OnTerminate :=
      OnThreadEnded;
    TPaintingThread(fPaintingThread).Resume;
  end
  else
  try
    try
      TmpCanvas := fOffScreenCanvas.Canvas;
      TmpClipRect := RectToRect2D(ClientRect);
      TmpCanvas.Lock;
      try
        if fShowGrid and not fGridOnTop then
          DrawGrid(ARect, TmpCanvas);
        if fDrawMode = DRAWMODE_NODRAW then
          Exit;
        if (fViewportObjects <> nil) then
          TmpIter := fViewportObjects.GetIterator
        else if not Assigned(fDrawing) or fDrawing.IsBlocked
          then
          Exit
        else
          TmpIter := fDrawing.GetListOfObjects;
        Tmp := TmpIter.First;
        try
          Cont := 0;
          if fCopingFrequency > 0 then
            while Tmp <> nil do
            begin
              DrawObject(Tmp, fOffScreenCanvas, TmpClipRect);
              Inc(Cont);
              if Cont = fCopingFrequency then
              begin
                DoCopyCanvas(False);
                Cont := 0;
              end;
              Tmp := TmpIter.Next;
            end
          else
            while Tmp <> nil do
            begin
              DrawObject(Tmp, fOffScreenCanvas, TmpClipRect);
              Tmp := TmpIter.Next;
            end;
        //TSY:
          Tmp := TmpIter.First;
          while Tmp <> nil do
          begin
            if Tmp is TObject2D then
              if (Tmp as TObject2D).HasControlPoints then
                DrawObjectControlPoints(Tmp, fOffScreenCanvas,
                  TmpClipRect);
            Tmp := TmpIter.Next;
          end;
        finally
          TmpIter.Free;
        end;
        if fShowGrid and fGridOnTop then
          DrawGrid(ARect, TmpCanvas);
      finally
        TmpCanvas.Unlock;
      end;
    except
    end;
  finally
    DoCopyCanvas(True);
    if Assigned(fOnEndRedraw) then
      fOnEndRedraw(Self);
  end;
end;

procedure TCADViewport.RepaintRect(const ARect: TRect2D);
begin
  UpdateViewport(ARect);
end;

procedure TCADViewport.DrawGrid(const ARect: TRect2D; const Cnv:
  TCanvas);
var
  CurrX, CurrY, Mult, D, DeltaX, DeltaY: TRealType;
  Pnt1, Pnt2: TPoint2D;
  N: Integer;
  procedure DrawGridLines(const DecCnv: TDecorativeCanvas; const
    DX, DY: TRealType);
  begin
    CurrX := Round(ARect.Left / DX) * DX;
    CurrY := Round(ARect.Bottom / DY) * DY;
    Pnt1 := ViewportToScreen(Point2D(CurrX, CurrY));
    Pnt2 := ViewportToScreen(Point2D(CurrX + DX, CurrY + DY));
    if (Pnt2.X - Pnt1.X > 10.0) and (Pnt1.Y - Pnt2.Y > 10.0)
      then
    begin
      while (CurrY <= ARect.Top) do
      begin
        Pnt1 := ViewportToScreen(Point2D(ARect.Left, CurrY));
        Pnt2 := ViewportToScreen(Point2D(ARect.Right, CurrY));
        DecCnv.MoveTo(Round(Pnt1.X), Round(Pnt1.Y));
        DecCnv.LineTo(Round(Pnt2.X), Round(Pnt2.Y));
        CurrY := CurrY + DY;
      end;
      while (CurrX <= ARect.Right) do
      begin
        Pnt1 := ViewportToScreen(Point2D(CurrX, ARect.Top));
        Pnt2 := ViewportToScreen(Point2D(CurrX, ARect.Bottom));
        DecCnv.MoveTo(Round(Pnt1.X), Round(Pnt1.Y));
        DecCnv.LineTo(Round(Pnt2.X), Round(Pnt2.Y));
        CurrX := CurrX + DX;
      end;
    end;
  end;
var
  TmpCnv: TDecorativeCanvas;
begin
  if (fGridDeltaX <= 0.0) or (fGridDeltaY <= 0.0) then
    Exit;
  TmpCnv := TDecorativeCanvas.Create(Cnv);
  D := (Log10((VisualRect.Right - VisualRect.Left) / fGridDeltaX)
    + Log10((VisualRect.Top - VisualRect.Bottom) / fGridDeltaY)) / 2 - 1;
  N := Round(D);
  Mult := IntPower(10, N);
  if N - D > -0.2 then
  begin
    if N - D > 0.2 then
      Mult := Mult / 5
    else
      Mult := Mult / 2;
  end;
  DeltaX := fGridDeltaX * Mult;
  DeltaY := fGridDeltaY * Mult;
  with Cnv do
  try
    SetBkMode(Canvas, False);
    Pen.Color := fGridColor;
    Pen.Width := 1;
    Pen.Mode := pmCopy;
    Pen.Style := psSolid;
    Brush.Color := fBackGroundColor;
    Brush.Style := bsSolid;
     // Draw the grid subdivisions if any.
    if ((fGridSubX > 0) and (fGridSubY > 0)) then
    begin
      TmpCnv.DecorativePen.SetPenStyle('10');
      DrawGridLines(TmpCnv, DeltaX / fGridSubX, DeltaY
        / fGridSubY);
      TmpCnv.DecorativePen.SetPenStyle('');
    end;
     // Draw the grid main divisions.
    Pen.Style := psSolid;
    DrawGridLines(TmpCnv, DeltaX, DeltaY);
     // Draw the main axes.
    Pen.Width := 2;
    Pnt1 := ViewportToScreen(Point2D(ARect.Left, 0.0));
    Pnt2 := ViewportToScreen(Point2D(ARect.Right, 0.0));
    MoveTo(Round(Pnt1.X), Round(Pnt1.Y));
    LineTo(Round(Pnt2.X), Round(Pnt2.Y));
    Pnt1 := ViewportToScreen(Point2D(0.0, ARect.Bottom));
    Pnt2 := ViewportToScreen(Point2D(0.0, ARect.Top));
    MoveTo(Round(Pnt1.X), Round(Pnt1.Y));
    LineTo(Round(Pnt2.X), Round(Pnt2.Y));
  finally
    TmpCnv.Free;
  end;
end;

function TCADViewport.GetInRepaint: Boolean;
begin
  Result := Assigned(fPaintingThread);
end;

procedure TCADViewport.Repaint;
begin
  if (csReadingState in ControlState) then
    Exit;
  if fTransparent then
    Parent.Repaint;
  RepaintRect(fVisualWindow);
end;

procedure TCADViewport.WaitForRepaintEnd;
begin
  if Assigned(fPaintingThread) then
  try
     // Devo aspettare.
    TPaintingThread(fPaintingThread).WaitFor;
  finally
    fPaintingThread := nil;
  end;
end;

procedure TCADViewport.StopRepaint;
begin
  StopPaintingThread;
end;

procedure TCADViewport.Refresh;
begin
  Invalidate;
end;

procedure TCADViewport.Invalidate;
begin
  if (csReadingState in ControlState) or
    (csLoading in ComponentState) then
  begin
    inherited;
    Exit;
  end;
  if (csDesigning in ComponentState) then
    inherited;
  if HandleAllocated then
    Paint;
end;

procedure TCADViewport.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (AComponent = Drawing) and (Operation = opRemove) then
  begin
    StopPaintingThread;
    Drawing := nil;
  end;
  inherited Notification(AComponent, Operation);
end;

procedure TCADViewport.ChangeViewportTransform(ViewWin:
  TRect2D);
var
  OldView: TRect2D;
begin
  StopRepaint;
  ViewWin := ReorderRect2D(ViewWin);
  OldView := fVisualWindow;
  if (ViewWin.Bottom = ViewWin.Top) or (ViewWin.Right =
    ViewWin.Left) then
    Exit;
  try
    fViewGuard.Enter;
    try
      fVisualWindow := ViewWin;
      UpdateViewportTransform;
    finally
      fViewGuard.Leave;
    end;
  except
    on Exception do
    begin
      fVisualWindow := OldView;
      try
        UpdateViewportTransform;
      except
      end;
    end;
  end;
end;

procedure TCADViewport.UpdateViewportTransform;
var
  NewTransf: TTransf2D;
begin
  StopRepaint;
  try
    NewTransf := BuildViewportTransform(fVisualWindow,
      ClientRect, fAspectRatio);
    fScreenToViewport := InvertTransform2D(NewTransf);
    fViewportToScreen := NewTransf;
    if Assigned(fOnViewMappingChanged) then
      fOnViewMappingChanged(Self);
  except
  end;
  Repaint;
end;

function TCADViewport.BuildViewportTransform(var ViewWin:
  TRect2D;
  const ScreenWin: TRect;
  const AspectRatio: TRealType): TTransf2D;
begin
  Result := IdentityTransf2D;
end;

procedure TCADViewport.ZoomWindow(const NewWindow: TRect2D);
begin
  ChangeViewportTransform(NewWindow);
end;

function TCADViewport.GetAperture(const L: Word): TRealType;
begin
  Result := GetPixelAperture.X * L;
end;

function TCADViewport.SetLayer(const L: TLayer): Boolean;
begin
  if (L <> nil) then
    Result := L.SetCanvas(fOffScreenCanvas)
  else
    Result := False;
end;

{function TCADViewport.GetPixelSizeX: TRealType;
begin
  Result :=
    (VisualRect.Right - VisualRect.Left) /
    (ClientRect.Right - ClientRect.Left);
end;

function TCADViewport.GetPixelSizeY: TRealType;
begin
  Result :=
    (VisualRect.Top - VisualRect.Bottom) /
    (ClientRect.Bottom - ClientRect.Top);
end;}

procedure TCADViewport.CalibrateCnv(const Cnv: TCanvas; XScale,
  YScale: TRealType);
var
  TmpWin: TRect2D;
  TmpAspect, LogWidth, LogHeight: Double;
begin
  StopRepaint;
  if (XScale = 0) or (YScale = 0) then Exit;
  TmpWin := fVisualWindow;
  // Questa Ŕ la dimensione di un pixel in mm.
  GetCanvasResolution(Cnv, LogHeight, LogWidth);
  try
    TmpAspect := LogHeight / LogWidth;
    TmpWin.Right := fVisualWindow.Left + LogWidth * Width *
      XScale;
    TmpWin.Top := fVisualWindow.Bottom + LogHeight * TmpAspect *
      Height * YScale;
    ChangeViewportTransform(TmpWin);
  except
  end;
end;

procedure TCADViewport.Calibrate(const XScale, YScale:
  TRealType);
begin
  CalibrateCnv(Canvas, XScale, YScale);
end;

procedure TCADViewport.MoveWindow(const NewStartX, NewStartY:
  TRealType);
var
  TmpWin: TRect2D;
  Temp: TRealType;
begin
  StopRepaint;
  Temp := (fVisualWindow.Right - fVisualWindow.Left);
  TmpWin.Left := NewStartX;
  TmpWin.Right := NewStartX + Temp;
  TmpWin.W1 := 1.0;
  Temp := fVisualWindow.Top - fVisualWindow.Bottom;
  TmpWin.Bottom := NewStartY;
  TmpWin.Top := NewStartY + Temp;
  TmpWin.W2 := 1.0;
  ChangeViewportTransform(TmpWin);
end;

procedure TCADViewport.ZoomCenter(const C: TPoint2D; const F: TRealType);
var
  TmpWin: TRect2D;
begin
  StopRepaint;
  TmpWin.Left := fVisualWindow.Left * F + C.X * (1 - F);
  TmpWin.Right := fVisualWindow.Right * F + C.X * (1 - F);
  TmpWin.W1 := 1.0;
  TmpWin.Top := fVisualWindow.Top * F + C.Y * (1 - F);
  TmpWin.Bottom := fVisualWindow.Bottom * F + C.Y * (1 - F);
  TmpWin.W2 := 1.0;
  ChangeViewportTransform(TmpWin);
end;

procedure TCADViewport.ZoomFrac(const FX, FY: TRealType; const F: TRealType);
var
  C: TPoint2D;
begin
  C := Point2D(
    fVisualWindow.Left * (1 - FX) + fVisualWindow.Right * FX,
    fVisualWindow.Bottom * (1 - FY) + fVisualWindow.Top * FY);
  ZoomCenter(C, F);
end;

procedure TCADViewport.ZoomSelCenter(const F: TRealType);
var
  C: TPoint2D;
begin
  C := Drawing.GetSelectionCenter;
  ZoomCenter(C, F);
end;

procedure TCADViewport.ZoomViewCenter(const F: TRealType);
begin
  ZoomFrac(0.5, 0.5, F);
end;

procedure TCADViewport.ZoomIn;
begin
  ZoomSelCenter(1 / Sqrt(2));
end;

procedure TCADViewport.ZoomOut;
begin
  ZoomViewCenter(Sqrt(2));
end;

procedure TCADViewport.PanWindow(const DeltaX, DeltaY:
  TRealType);
var
  TmpWin: TRect2D;
begin
  StopRepaint;
  TmpWin.Left := fVisualWindow.Left + DeltaX;
  TmpWin.Right := fVisualWindow.Right + DeltaX;
  TmpWin.W1 := 1.0;
  TmpWin.Bottom := fVisualWindow.Bottom + DeltaY;
  TmpWin.Top := fVisualWindow.Top + DeltaY;
  TmpWin.W2 := 1.0;
  if Round(TmpWin.Right - TmpWin.Left) > 300 then
    TmpWin.W2 := 1.0;
  ChangeViewportTransform(TmpWin);
end;

procedure TCADViewport.PanWindowFraction(const FX, FY: TRealType);
begin
  PanWindow(
    FX * (fVisualWindow.Right - fVisualWindow.Left),
    FY * (fVisualWindow.Bottom - fVisualWindow.Top));
end;

function TCADViewport.AsMetafile: TMetaFile;
var
  Cnv: TMetaFileCanvas;
  Inch, PPI_X, PPI_Y, I, II: Integer;
  H, W, H_MM, W_MM, AAA: TRealType;
  Rect2D: TRect2D;
  B_MM, B: TRealType;
begin
  Rect2D := (fDrawing as TDrawing2D).DrawingExtension;
  B_MM := (fDrawing as TDrawing2D).Border;
  with Rect2D do
  begin
    W_MM := (Right - Left) * (fDrawing as TDrawing2D).PicScale + B_MM * 2;
    H_MM := (Top - Bottom) * (fDrawing as TDrawing2D).PicScale + B_MM * 2;
  end;

  //How to get device PPI?//  DC: HDC;
  {DC := GetDC(0);
  PPI_X := GetDeviceCaps(DC, LOGPIXELSX);
  PPI_Y := GetDeviceCaps(DC, LOGPIXELSY);
  ReleaseDC(0,DC);}

  Result := TMetaFile.Create;
  Cnv := TMetaFileCanvas.Create(Result, Result.Handle);
  Cnv.Free;
  GetMetaFileResolution(Result, PPI_X, PPI_Y);
  Result.Free;

  Result := TMetaFile.Create;
  // szlMillimeters device size in mm
  // szlDevice device size in pixels
  //(fDrawing as TDrawing2D).PicUnitLength := 0.005;
  W := (W_MM - 2 * B_MM) / (fDrawing as TDrawing2D).PicUnitLength;
  H := (H_MM - 2 * B_MM) / (fDrawing as TDrawing2D).PicUnitLength;
  B := B_MM / (fDrawing as TDrawing2D).PicUnitLength;
  Result.Enhanced := True;
  Inch := Round(25.4 / (fDrawing as TDrawing2D).PicUnitLength);
  {Result.Width := Round((W + 2 * B) * PPI_X / Inch);
  Result.Height := Round((H + 2 * B) * PPI_Y / Inch);}
  //Result.MMHeight := Round((H_MM+2*B_MM)*100*PPI_X / Inch);
  //Result.MMWidth := Round((W_MM+2*B_MM)*100* PPI_Y / Inch);
  Result.Width := Round((W + 2. * B) * PPI_X / Inch);
  Result.Height := Round((H + 2. * B) * PPI_Y / Inch);
  {Result.MMHeight := Round((H_MM+2*B_MM)*100);
  Result.MMWidth := Round((W_MM+2*B_MM)*100);
  PPI_X:=Round(Result.Height*2540./Result.MMHeight);
  PPI_Y:=Round(Result.Width*2540./Result.MMWidth);
  Result.Width := Round((W + 2. * B) * PPI_X / Inch);
  Result.Height := Round((H + 2. * B) * PPI_Y / Inch);}
  Cnv := TMetaFileCanvas.CreateWithComment(Result, Result.Handle,
    'TpX drawing tool',
    (fDrawing as TDrawing2D).Caption + ' :: ' +
    (fDrawing as TDrawing2D).Comment);
    {hdc = BeginPaint(hwnd, &ps);
    GetClientRect(hwnd, &rc);
    SetMapMode(hdc, MM_ANISOTROPIC);
    SetWindowExtEx(hdc, 100, 100, NULL);
    SetViewportExtEx(hdc, rc.right, rc.bottom, NULL);
    Polyline(hdc, ppt, cpt);
    EndPaint(hwnd, &ps);}
  {GetEnhMetaFileHeader(Cnv.Handle, SizeOf(EMFHeader), @EMFHeader);
  PPI_X := Round(2540. * EMFHeader.szlDevice.CX / EMFHeader.szlMillimeters.CX);
  PPI_Y := Round(2540. * EMFHeader.szlDevice.CY / EMFHeader.szlMillimeters.CY);}
  ChangeCanvasResolution(Cnv, Inch, PPI_X, PPI_Y);
  //PPI_X:=Round(Result.Height*2540/Result.MMHeight);
  //PPI_Y:=Round(Result.Width*2540/Result.MMWidth);
  //(fDrawing as TDrawing2D).FactorMM :=
  //  1 / (fDrawing as TDrawing2D).PicUnitLength{ * PPI_X / Inch};
  try
    //CopyToCanvas(Cnv, cmAspect, cvActual, 1, 1);
    //CopyToCanvas(Cnv, cmAspect, cvExtension, 1, 1);
    //CopyToCanvas(Cnv, cmAspect, cvScale, 0.1, 0.1);
    //Cnv.LineTo(Result.Width, Result.Height);
    //LineTo(Cnv.Handle, Result.Width div 2, Result.Height div 2);
    CopyToCanvasBasic(Cnv,
      Rect(Round(B + PPI_X * 0 + PPI_Y * 0), Round(B),
      Round(W) + Round(B), Round(H) + Round(B)));
  finally
    Cnv.Free;
  end;
  GetMetaFileResolution(Result, PPI_X, PPI_Y);

  Result.MMHeight := Round((H_MM + 2 * B_MM) * 100 + PPI_X * 0 + PPI_Y * 0);
  Result.MMWidth := Round((W_MM + 2 * B_MM) * 100);
end;

function TCADViewport.AsBitmap: TBitmap;
var
  I, II, BB: Integer;
  H, W: Integer;
  H_MM, W_MM, PPI: TRealType;
  Rect2D: TRect2D;
  MF: TMetaFile;
  big_bmp: TBitmap;
begin
  MF := AsMetafile;
  Rect2D := (fDrawing as TDrawing2D).DrawingExtension;
  with Rect2D do
  begin
    W_MM := (Right - Left) * (fDrawing as TDrawing2D).PicScale;
    H_MM := (Top - Bottom) * (fDrawing as TDrawing2D).PicScale;
  end;
  //PPI := 150;
  PPI := 25.4 / (fDrawing as TDrawing2D).PicUnitLength;
  W := Round(W_MM / 25.4 * PPI);
  H := Round(H_MM / 25.4 * PPI);
  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  BB := 3;
  Result.Width := W + BB * 2;
  Result.Height := H + BB * 2;
  Result.Width := Result.Width div 3;
  Result.Height := Result.Height div 3;
  //CopyToCanvasBasic(Result.Canvas,    Rect(BB, BB, W + BB, H + BB));
  big_bmp := TBitmap.Create;
  big_bmp.PixelFormat := pf24bit;
  big_bmp.Width := Result.Width * 3;
  big_bmp.Height := Result.Height * 3;
  big_bmp.Canvas.StretchDraw(Rect(0, 0, big_bmp.Width,
    big_bmp.Height), MF);
  FastAntiAliasPicture(big_bmp, Result);
  //Result.Canvas.StretchDraw(Rect(0, 0, Result.Width,    Result.Height), MF);
  //Result.Canvas.Draw(0,0,MF);
  MF.Free;
end;

procedure TCADViewport.CopyToClipboard;
var
  MetaFile: TMetaFile;
begin
  StopRepaint;
  MetaFile := AsMetafile;
  PutMetafileToClipboard(MetaFile);
  MetaFile.Free;
end;

procedure TCADViewport.CopyToCanvasBasic(const Cnv: TCanvas;
  const Rect: TRect);
var
  OldView: TRect2D;
  fOldAspect: TRealType;
begin
  if not Assigned(fDrawing) then
    Exit;
  StopRepaint;
  OldView := VisualRect;
  BeginUpdate;
  fOldAspect := fAspectRatio;
  try
    fAspectRatio := 0;
    fAspectRatio := fOldAspect;
    //ZoomToExtension;
    CopyRectToCanvas((fDrawing as TDrawing2D).GetExtension,
      Rect, Cnv, cmAspect);
    //CopyRectToCanvas((fDrawing as TDrawing2D).GetExtension,      Rect, Cnv, cmNone);
  finally
    fAspectRatio := fOldAspect;
    ZoomWindow(OldView);
    EndUpdate;
  end;
end;

procedure TCADViewport.CopyToCanvas(const Cnv: TCanvas;
  const Mode: TCanvasCopyMode;
  const View: TCanvasCopyView;
  const XScale, YScale: TRealType);
var
  OldView: TRect2D;
  fOldAspect: TRealType;
begin
  if not Assigned(fDrawing) then
    Exit;
  StopRepaint;
  OldView := VisualRect;
  BeginUpdate;
  fOldAspect := fAspectRatio;
  try
    fAspectRatio := 0;
    case View of
      cvExtension: ZoomToExtension;
      cvScale: CalibrateCnv(Cnv, XScale, YScale);
    end;
    fAspectRatio := fOldAspect;
    CopyRectToCanvas(VisualRect, ClientRect, Cnv, Mode);
  finally
    fAspectRatio := fOldAspect;
    ZoomWindow(OldView);
    EndUpdate;
  end;
end;

function TCADViewport.GetCopyRectViewportToScreen(CADRect:
  TRect2D;
  const CanvasRect: TRect;
  const Mode: TCanvasCopyMode): TTransf2D;
begin
  Result := GetViewportToScreen;
end;

function TCADViewport.ScreenToViewport(const SPt: TPoint2D):
  TPoint2D;
begin
  Result := TransformPoint2D(SPt, fScreenToViewport);
end;

function TCADViewport.ViewportToScreen(const WPt: TPoint2D):
  TPoint2D;
begin
  Result := CartesianPoint2D(TransformPoint2D(WPt,
    fViewportToScreen));
end;

function TCADViewport.GetViewportToScreen: TTransf2D;
begin
  Result := fViewportToScreen;
end;

function TCADViewport.GetScreenToViewport: TTransf2D;
begin
  Result := fScreenToViewport;
end;

function TCADViewport.GetPixelAperture: TPoint2D;
begin
  Result.X := Abs(fScreenToViewport[1, 1]);
  Result.Y := Abs(fScreenToViewport[2, 2]);
  Result.W := 1.0;
end;

// =====================================================================
// TRuler
// =====================================================================

procedure TRuler.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TRuler.SetOwnerView(V: TCADViewport);
begin
  if V <> fOwnerView then
  begin
    fOwnerView := V;
    Visible := fOwnerView.ShowRulers;
    Invalidate;
  end;
end;

procedure TRuler.SetOrientation(O: TRulerOrientationType);
begin
  if fOrientation <> O then
  begin
    fOrientation := O;
    Invalidate;
  end;
end;

procedure TRuler.SetSize(S: Integer);
begin
  if S <> FSize then
  begin
    FSize := S;
    Invalidate;
  end;
end;

procedure TRuler.SetFontSize(S: Integer);
begin
  if S <> fFontSize then
  begin
    fFontSize := S;
    Invalidate;
  end;
end;

procedure TRuler.SetStepSize(S: TRealType);
begin
  if S <> fStepSize then
  begin
    fStepSize := S;
    Invalidate;
  end;
end;

procedure TRuler.SetStepDivisions(D: Integer);
begin
  if D <> fStepDivisions then
  begin
    fStepDivisions := D;
    Invalidate;
  end;
end;

procedure TRuler.SetTicksColor(C: TColor);
begin
  if C <> fTicksColor then
  begin
    fTicksColor := C;
    Invalidate;
  end;
end;

constructor TRuler.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fOwnerView := nil;
  FSize := 20;
  fFontSize := 6;
  fStepSize := 10.0;
  fStepDivisions := 5;
  fOrientation := otVertical;
  fTicksColor := clBlack;
  Color := clWhite;
  Canvas.Font.Name := 'Verdana';
  Width := FSize;
  Height := FSize * 4;
end;

procedure TRuler.Paint;
var
  TmpStep, TmpVal: TRealType;
  TmpPt: TPoint;
  LastPt, MinSize, XShift, YShift: Integer;
begin
  if fOwnerView = nil then
    Exit;
  Visible := fOwnerView.ShowRulers;
  if not Visible then Exit;
  with Canvas do
  begin
    Font.Size := fFontSize;
    Font.Color := fTicksColor;
    Brush.Color := Color;
    Pen.Color := fTicksColor;
    Pen.Width := 1;
    Rectangle(ClientRect);
    //FillRect(ClientRect);
    //FrameRect(ClientRect);
    SetBkMode(Canvas, False);
    XShift := fOwnerView.Left - Left;
    YShift := fOwnerView.Top - Top;
    case fOrientation of
      otOrizontal:
        begin
          MoveTo(ClientRect.Left + XShift, ClientRect.Top);
          LineTo(ClientRect.Right + XShift, ClientRect.Top);
          TmpVal := Trunc(fOwnerView.VisualRect.Left / fStepSize)
            * fStepSize;
          TmpStep := fStepSize;
          MinSize := TextWidth(Format('%12.2f', [TmpVal]));
        // Trova lo step ottimo.
          TmpPt :=
            Point2DToPoint(fOwnerView.ViewportToScreen(Point2D(TmpVal -
            fStepSize, 0)));
          //TmpPt.X := TmpPt.X + XShift;
          LastPt := TmpPt.X;
          while TmpVal <= fOwnerView.VisualRect.Right do
          begin
            TmpPt :=
              Point2DToPoint(fOwnerView.ViewportToScreen(Point2D(TmpVal, 0)));
            if Abs(TmpPt.X - LastPt) > MinSize then
              Break;
            TmpVal := TmpVal + TmpStep;
            TmpStep := TmpStep * 2.0;
          end;
        // Disegna il righello.
          TmpVal := Trunc(fOwnerView.VisualRect.Left / TmpStep)
            * TmpStep;
          if TmpStep / fOwnerView.VisualRect.Right < 0.01 then
            Exit;
          while TmpVal <= fOwnerView.VisualRect.Right do
          begin
            TmpPt :=
              Point2DToPoint(fOwnerView.ViewportToScreen(Point2D(TmpVal, 0)));
            MoveTo(TmpPt.X + XShift, ClientRect.Top);
            LineTo(TmpPt.X + XShift, ClientRect.Bottom);
            //TSY: corrected
            TextOut(TmpPt.X + XShift + 2, ClientRect.Top + FSize
              div 2,
              Format('%.6g', [TmpVal]));
            //TextOut(TmpPt.X, ClientRect.Bottom - Font.Size - 2,              Format('%6.2f', [TmpVal]));
            TmpVal := TmpVal + TmpStep;
          end;
        // Subdivisions.
          if fStepDivisions > 0 then
          begin
            TmpStep := TmpStep / fStepDivisions;
            TmpVal := Trunc(fOwnerView.VisualRect.Left / TmpStep)
              * TmpStep;
            while TmpVal <= fOwnerView.VisualRect.Right do
            begin
              TmpPt :=
                Point2DToPoint(fOwnerView.ViewportToScreen(Point2D(TmpVal, 0)));
              MoveTo(TmpPt.X + XShift, ClientRect.Top);
              LineTo(TmpPt.X + XShift, ClientRect.Top + FSize
                div
                2);
              TmpVal := TmpVal + TmpStep;
            end;
          end;
        end;
      otVertical:
        begin
          MoveTo(ClientRect.Right - 1, ClientRect.Top + YShift);
          LineTo(ClientRect.Right - 1, ClientRect.Bottom +
            YShift);
          TmpVal := Trunc(fOwnerView.VisualRect.Bottom /
            fStepSize) * fStepSize;
          TmpStep := fStepSize;
          MinSize := 2 * Font.Size;
        // Trova lo step ottimo.
          TmpPt :=
            Point2DToPoint(fOwnerView.ViewportToScreen(Point2D(0,
            TmpVal - fStepSize)));
          LastPt := TmpPt.Y;
          while TmpVal <= fOwnerView.VisualRect.Top do
          begin
            TmpPt :=
              Point2DToPoint(fOwnerView.ViewportToScreen(Point2D(0, TmpVal)));
            if Abs(TmpPt.Y - LastPt) > MinSize then
              Break;
            TmpVal := TmpVal + TmpStep;
            TmpStep := TmpStep * 2.0;
          end;
        // Disegna il righello.
          TmpVal := Trunc(fOwnerView.VisualRect.Bottom / TmpStep)
            * TmpStep;
          if TmpStep / fOwnerView.VisualRect.Right < 0.01 then
            Exit;
          while TmpVal <= fOwnerView.VisualRect.Top do
          begin
            TmpPt :=
              Point2DToPoint(fOwnerView.ViewportToScreen(Point2D(0, TmpVal)));
            MoveTo(ClientRect.Left, TmpPt.Y + YShift);
            LineTo(ClientRect.Right, TmpPt.Y + YShift);
            //TextOut(ClientRect.Left + FSize div 2, TmpPt.Y,              Format('%-6.2f', [TmpVal]));
            TextOut(ClientRect.Left + 1, TmpPt.Y + YShift,
              Format('%-.6g', [TmpVal]));
            TmpVal := TmpVal + TmpStep;
          end;
        // Subdivisions.
          if fStepDivisions > 0 then
          begin
            TmpStep := TmpStep / fStepDivisions;
            TmpVal := Trunc(fOwnerView.VisualRect.Bottom /
              TmpStep) * TmpStep;
            while TmpVal <= fOwnerView.VisualRect.Top do
            begin
              TmpPt :=
                Point2DToPoint(fOwnerView.ViewportToScreen(Point2D(0, TmpVal)));
              MoveTo(ClientRect.Right - FSize div 2, TmpPt.Y +
                YShift);
              LineTo(ClientRect.Right, TmpPt.Y + YShift);
              TmpVal := TmpVal + TmpStep;
            end;
          end;
        end;
    end;
  end;
end;

procedure TRuler.SetMark(Value: TRealType);
var
  TmpPt: TPoint;
begin
  Paint;
  if fOwnerView = nil then
    Exit;
  with Canvas do
  begin
    Pen.Color := fTicksColor;
    Pen.Width := 3;
    case fOrientation of
      otOrizontal:
        begin
          TmpPt :=
            Point2DToPoint(fOwnerView.ViewportToScreen(Point2D(Value, 0)));
          MoveTo(TmpPt.X, ClientRect.Top);
          LineTo(TmpPt.X, ClientRect.Bottom);
        end;
      otVertical:
        begin
          TmpPt :=
            Point2DToPoint(fOwnerView.ViewportToScreen(Point2D(0,
            Value)));
          MoveTo(ClientRect.Left, TmpPt.Y);
          LineTo(ClientRect.Right, TmpPt.Y);
        end;
    end;
  end;
end;

// =====================================================================
// TObject2DHandler
// =====================================================================

constructor TObject2DHandler.Create(AObject: TObject2D);
begin
  inherited Create;

  fHandledObject := AObject;
  fRefCount := 1;
end;

destructor TObject2DHandler.Destroy;
begin
  if Assigned(fHandledObject) then
    fHandledObject.fHandler := nil;
  inherited;
end;

procedure TObject2DHandler.FreeInstance;
begin
  Dec(fRefCount);
  if fRefCount > 0 then
    Exit;
  inherited;
end;

// =====================================================================
// TObject2D
// =====================================================================

constructor TObject2D.Create(ID: Integer);
begin
  inherited Create(ID);
  fBox := Rect2D(0, 0, 0, 0);
  fDrawBoundingBox := False;
  fHandler := nil;
end;

destructor TObject2D.Destroy;
begin
  if Assigned(fHandler) then
    fHandler.Free;
  inherited Destroy;
end;

constructor TObject2D.CreateFromStream(const Stream: TStream;
  const Version: TCADVersion);
var
  TmpTransf: TTransf2D;
begin
  inherited;
  fHandler := nil;
end;

procedure TObject2D.SaveToStream(const Stream: TStream);
begin
  inherited SaveToStream(Stream);
end;

procedure TObject2D.Assign(const Obj: TGraphicObject);
begin
  if (Obj = Self) then
    Exit;
  inherited Assign(Obj);
  if Obj is TObject2D then
  begin
    fBox := TObject2D(Obj).fBox;
    if fHandler <> TObject2D(Obj).fHandler then
      SetSharedHandler(TObject2D(Obj).fHandler);
  end;
end;

procedure TObject2D.MoveTo(ToPt, DragPt: TPoint2D);
var
  TmpTransf: TTransf2D;
begin
  ToPt := CartesianPoint2D(ToPt);
  DragPt := CartesianPoint2D(DragPt);
  TmpTransf := Translate2D(ToPt.X - DragPt.X, ToPt.Y -
    DragPt.Y);
  TransForm(TmpTransf);
end;

function TObject2D.OnMe(PT: TPoint2D; Aperture: TRealType; var
  Distance: TRealType): Integer;
var
  TmpBox: TRect2D;
begin
  TmpBox := EnlargeBoxDelta2D(Box, Aperture);
  Distance := MaxCoord;
  Result := PICK_NOOBJECT;
  if not fEnabled then
    Exit;
  if IsPointInCartesianBox2D(PT, TmpBox) then
  begin
    Distance := Aperture;
    Result := PICK_INBBOX;
  end;
  if Assigned(fHandler) then
    Result := MaxIntValue([Result, fHandler.OnMe(Self, PT,
        Aperture, Distance)]);
end;

procedure TObject2D.DrawControlPoints(const VT: TTransf2D; const
  Cnv: TDecorativeCanvas;
  const ClipRect2D: TRect2D; const Width: Integer);
begin
  // Draw the bounding box.
  if fDrawBoundingBox and (Cnv.Canvas.Pen.Mode <> pmXOr) then
    DrawBoundingBox2D(Cnv, Box, ClipRect2D, VT);
  if Assigned(fHandler) then
    fHandler.DrawControlPoints(Self, VT, Cnv, Width);
end;

procedure TObject2D.TransForm(const T: TTransf2D);
begin
  //!!!
end;

function TObject2D.IsVisible(const Clip: TRect2D; const
  DrawMode: Integer): Boolean;
begin
  Result := False;
  if not Visible then
    Exit;
  if fBox.Left > Clip.Right then
    Exit
  else if fBox.Right < Clip.Left then
    Exit;
  if fBox.Bottom > Clip.Top then
    Exit
  else if fBox.Top < Clip.Bottom then
    Exit;
  Result := True;
end;

procedure TObject2D.SetSharedHandler(const Hndl:
  TObject2DHandler);
begin
  if Assigned(fHandler) then
    fHandler.Free;
  fHandler := Hndl;
  if (Hndl <> nil) then
    Inc(fHandler.fRefCount);
end;

procedure TObject2D.SetHandler(const Hndl:
  TObject2DHandlerClass);
begin
  if Assigned(fHandler) then
    fHandler.Free;
  if (Hndl <> nil) then
    fHandler := Hndl.Create(Self)
  else
    fHandler := nil;
end;

// =====================================================================
// TContainer2D
// =====================================================================

function StringToBlockName(const Str: string): TSourceBlockName;
var
  Cont: Integer;
begin
  for Cont := 0 to 12 do
  begin
    if Cont < Length(Str) then
      Result[Cont] := Str[Cont + 1]
    else
      Result[Cont] := #0;
  end;
end;

constructor TContainer2D.Create(ID: Integer);
begin
  inherited Create(ID);

  fObjects := TGraphicObjList.Create;
  fObjects.FreeOnClear := True;
end;

constructor TContainer2D.CreateSpec(ID: Integer; const Objs: array
  of TObject2D);
var
  Cont: Word;
begin
  inherited Create(ID);

  fObjects := TGraphicObjList.Create;
  fObjects.FreeOnClear := True;
  for Cont := Low(Objs) to High(Objs) do
    if Objs[Cont] <> nil then fObjects.Add(Objs[Cont]);
  UpdateExtension(Self);
end;

procedure TContainer2D._UpdateExtension;
var
  TmpIter: TGraphicObjIterator;
begin
  // Crea un iterator temporaneo.
  TmpIter := fObjects.GetIterator;
  try
    if TmpIter.Count = 0 then
    begin
      fBox := Rect2D(0, 0, 0, 0);
      Exit;
    end;
    fBox := TObject2D(TmpIter.First).Box;
    while TmpIter.Next <> nil do
      fBox := BoxOutBox2D(fBox, TObject2D(TmpIter.Current).Box);
  finally // Libera l'iterator
    TmpIter.Free;
  end;
end;

destructor TContainer2D.Destroy;
begin
  fObjects.Free;
  inherited Destroy;
end;

procedure TContainer2D.SaveToStream(const Stream: TStream);
var
  TmpObj: TObject2D;
  TmpLong: Integer;
  TmpWord: Word;
  TmpIter: TGraphicObjIterator;
begin
  inherited SaveToStream(Stream);
  // Crea un iterator temporaneo.
  TmpIter := fObjects.GetIterator;
  with Stream do
  try
     { Write the number of objects in the container. }
    TmpLong := fObjects.Count;
    Write(TmpLong, SizeOf(TmpLong));
     { Now write the objects in the container. }
    TmpObj := TObject2D(TmpIter.First);
    while TmpObj <> nil do
    begin
      TmpWord := CADSysFindClassIndex(TmpObj.ClassName);
        { Save the class index. }
      Write(TmpWord, SizeOf(TmpWord));
        { Save the object. }
      TmpObj.SaveToStream(Stream);
      TmpObj := TObject2D(TmpIter.Next);
    end;
  finally // Libera l'iterator
    TmpIter.Free;
  end;
end;

constructor TContainer2D.CreateFromStream(const Stream: TStream;
  const Version: TCADVersion);
var
  TmpClass: TGraphicObjectClass;
  TmpObj: TGraphicObject;
  TmpLong: Integer;
  TmpWord: Word;
begin
  inherited;
  with Stream do
  begin
     { Read the number of objects in the container. }
    Read(TmpLong, SizeOf(TmpLong));
    fObjects := TGraphicObjList.Create;
    fObjects.FreeOnClear := True;
     { Now read the objects for the container. }
    while TmpLong > 0 do
    begin
        { Read the type of object. }
      Read(TmpWord, SizeOf(TmpWord));
        { Retrive the class type from the registered classes. }
      TmpClass := CADSysFindClassByIndex(TmpWord);
      TmpObj := TmpClass.CreateFromStream(Stream, Version);
      TmpObj.UpdateExtension(Self);
      fObjects.Add(TmpObj);
      Dec(TmpLong);
    end;
  end;
  UpdateExtension(Self);
end;

procedure TContainer2D.Assign(const Obj: TGraphicObject);
var
  TmpIter: TGraphicObjIterator;
  TmpClass: TGraphicObjectClass;
  TmpObj: TGraphicObject;
begin
  if (Obj = Self) then
    Exit;
  inherited;
  if Obj is TContainer2D then
  begin
    if fObjects = nil then
    begin
      fObjects := TGraphicObjList.Create;
      fObjects.FreeOnClear := True;
    end
    else
      fObjects.Clear;
     // Copia creando gli oggetti contenuti.
    if TContainer2D(Obj).fObjects.HasExclusiveIterators then
      raise
        ECADListBlocked.Create('TContainer2D.Assign: The list has an exclusive iterator.');
     // Alloca un iterator locale
    TmpIter := TContainer2D(Obj).fObjects.GetIterator;
    try
      repeat
        TmpClass :=
          TGraphicObjectClass(TmpIter.Current.ClassType);
        TmpObj := TmpClass.Create(TmpIter.Current.ID);
        TmpObj.Assign(TmpIter.Current);
        fObjects.Add(TmpObj);
      until TmpIter.Next = nil;
    finally
      TmpIter.Free;
    end;
  end;
end;

procedure TContainer2D.UpdateSourceReferences(const BlockList:
  TGraphicObjIterator);
var
  TmpObj: TObject2D;
  TmpIter: TGraphicObjIterator;
begin
  // Crea un iterator temporaneo.
  TmpIter := fObjects.GetIterator;
  try
    TmpObj := TObject2D(TmpIter.First);
    while TmpObj <> nil do
    begin
      if (TmpObj is TSourceBlock2D) then
        TSourceBlock2D(TmpObj).UpdateSourceReferences(BlockList)
      else if (TmpObj is TBlock2D) then
        TBlock2D(TmpObj).UpdateReference(BlockList);
      TmpObj := TObject2D(TmpIter.Next);
    end;
  finally // Libera l'iterator
    TmpIter.Free;
  end;
  UpdateExtension(Self);
end;

procedure TContainer2D.Draw(VT: TTransf2D; const Cnv:
  TDecorativeCanvas;
  const ClipRect2D: TRect2D; const DrawMode: Integer);
var
  TmpObj: TObject2D;
  TmpTransf: TTransf2D;
  TmpIter: TGraphicObjIterator;
  TmpPen: TPen;
  TmpBrush: TBrush;
begin
  // Crea un iterator temporaneo.
  TmpIter := fObjects.GetIterator;
  TmpPen := TPen.Create;
  TmpBrush := TBrush.Create;
  try
    { Transform the container. }
    TmpTransf := VT;
    TmpObj := TObject2D(TmpIter.First);
    TmpPen.Assign(Cnv.Canvas.Pen);
    TmpBrush.Assign(Cnv.Canvas.Brush);
    while TmpObj <> nil do
    begin
      Cnv.Canvas.Pen.Assign(TmpPen);
      Cnv.Canvas.Brush.Assign(TmpBrush);
       { Transform the object in the container. }
      TmpObj.Draw(TmpTransf, Cnv, ClipRect2D, DrawMode);
      TmpObj := TObject2D(TmpIter.Next);
    end;
  finally
    TmpPen.Free;
    TmpBrush.Free;
    TmpIter.Free;
  end;
end;

function TContainer2D.OnMe(PT: TPoint2D; Aperture: TRealType;
  var Distance: TRealType): Integer;
var
  TmpObj: TObject2D;
  MinDist: TRealType;
  TmpIter: TGraphicObjIterator;
begin
  Result := inherited OnMe(PT, Aperture, Distance);
  if Result = PICK_INBBOX then
  begin
     // Crea un iterator temporaneo.
    TmpIter := fObjects.GetIterator;
    try
       { Check all the objects in the container. }
      TmpObj := TObject2D(TmpIter.First);
      MinDist := 2.0 * Aperture;
      while TmpObj <> nil do
      begin
        if (TmpObj.OnMe(PT, Aperture, Distance) >= PICK_INOBJECT)
          and
          (Distance < MinDist) then
        begin
          MinDist := Distance;
          Result := TmpObj.ID;
        end;
        TmpObj := TObject2D(TmpIter.Next);
      end;
      Distance := MinDist;
    finally
      TmpIter.Free;
    end;
  end;
end;

procedure TContainer2D.DrawControlPoints(const VT: TTransf2D;
  const Cnv: TDecorativeCanvas;
  const ClipRect2D: TRect2D; const Width: Integer);
begin
  if fObjects.Count > 0 then
    inherited;
end;

// =====================================================================
// TSourceBlock2D
// =====================================================================

constructor TSourceBlock2D.Create(ID: Integer);
begin
  inherited Create(ID);

  fName := '';
  fLibraryBlock := False;
  fNReference := 0;
end;

constructor TSourceBlock2D.CreateSpec(ID: Integer; const Name:
  TSourceBlockName; const Objs: array of TObject2D);
begin
  inherited CreateSpec(ID, Objs);

  fName := Name;
  fLibraryBlock := False;
  fNReference := 0;
end;

destructor TSourceBlock2D.Destroy;
begin
  if fNReference > 0 then
    raise
      ECADSourceBlockIsReferenced.Create('TSourceBlock2D.Destroy: This source block is referenced and cannot be deleted');
  inherited Destroy;
end;

constructor TSourceBlock2D.CreateFromStream(const Stream:
  TStream; const Version: TCADVersion);
begin
  inherited;
  Stream.Read(fToBeSaved, SizeOf(fToBeSaved));
  Stream.Read(fLibraryBlock, SizeOf(fLibraryBlock));
  Stream.Read(fName, SizeOf(fName));
  fNReference := 0;
end;

procedure TSourceBlock2D.SaveToStream(const Stream: TStream);
begin
  inherited SaveToStream(Stream);
  Stream.Write(fToBeSaved, SizeOf(fToBeSaved));
  Stream.Write(fLibraryBlock, SizeOf(fLibraryBlock));
  Stream.Write(fName, SizeOf(fName));
end;

procedure TSourceBlock2D.Assign(const Obj: TGraphicObject);
begin
  if (Obj = Self) then
    Exit;
  inherited;
  if Obj is TSourceBlock2D then
    fToBeSaved := TSourceBlock2D(Obj).fToBeSaved;
end;

// =====================================================================
// TBlock2D
// =====================================================================

procedure TBlock2D.SetSourceBlock(const Source: TSourceBlock2D);
begin
  if not Assigned(Source) then
    raise
      Exception.Create('TBlock2D.SetSourceBlock: Invalid parameter');
  if (fSourceBlock <> Source) then
  begin
    if Assigned(fSourceBlock) and (fSourceBlock.fNReference > 0)
      then
      Dec(fSourceBlock.fNReference);
    fSourceBlock := Source;
    fSourceName := Source.Name;
    Inc(fSourceBlock.fNReference);
    UpdateExtension(Self);
  end;
end;

procedure TBlock2D.SetOriginPoint(PT: TPoint2D);
begin
  fOriginPoint := PT;
  UpdateExtension(Self);
end;

constructor TBlock2D.Create(ID: Integer);
begin
  inherited Create(ID);

  fOriginPoint := Point2D(0, 0);
  fSourceName := '';
  fSourceBlock := nil;
  fSourceName := '';
end;

constructor TBlock2D.CreateSpec(ID: Integer; const Source:
  TSourceBlock2D);
begin
  inherited Create(ID);

  if not Assigned(Source) then
    raise
      Exception.Create('TBlock2D.Create: Invalid parameter');
  fOriginPoint := Point2D(0, 0);
  fSourceName := '';
  fSourceBlock := Source;
  fSourceName := Source.Name;
  fBox := Source.Box;
  Inc(fSourceBlock.fNReference);
  UpdateExtension(Self);
end;

destructor TBlock2D.Destroy;
begin
  if Assigned(fSourceBlock) and (fSourceBlock.fNReference > 0)
    then
    Dec(fSourceBlock.fNReference);
  inherited Destroy;
end;

constructor TBlock2D.CreateFromStream(const Stream: TStream;
  const Version: TCADVersion);
begin
  { Load the standard properties }
  inherited;
  with Stream do
  begin
     { TDrawing will use the value of FSourceName to find out the reference of the source block. }
    Read(fSourceName, SizeOf(fSourceName));
    Read(fOriginPoint, SizeOf(fOriginPoint));
  end;
  fSourceBlock := nil;
end;

procedure TBlock2D.SaveToStream(const Stream: TStream);
begin
  { Save the standard properties }
  inherited SaveToStream(Stream);
  with Stream do
  begin
     { Save the ID of the source block. }
    Write(fSourceName, SizeOf(fSourceName));
    Write(fOriginPoint, SizeOf(fOriginPoint));
  end;
end;

procedure TBlock2D.Assign(const Obj: TGraphicObject);
begin
  if (Obj = Self) then
    Exit;
  inherited;
  if Obj is TBlock2D then
  begin
    if Assigned(fSourceBlock) and (fSourceBlock.fNReference > 0)
      then
      Dec(fSourceBlock.fNReference);
    fSourceBlock := TBlock2D(Obj).fSourceBlock;
    fSourceName := fSourceBlock.Name;
    fOriginPoint := TBlock2D(Obj).OriginPoint;
    Inc(fSourceBlock.fNReference);
    UpdateExtension(Self);
  end;
end;

procedure TBlock2D.UpdateReference(const BlockList:
  TGraphicObjIterator);
var
  TmpSource: TSourceBlock2D;
begin
  TmpSource := BlockList.First as TSourceBlock2D;
  while TmpSource <> nil do
  begin
    if TmpSource.Name = fSourceName then
    begin
      fSourceBlock := TmpSource;
      UpdateExtension(Self);
      Exit;
    end;
    TmpSource := BlockList.Next as TSourceBlock2D;
  end;
  raise
    ECADListObjNotFound.Create('TBlock2D.UpdateReference: Source block not found');
end;

procedure TBlock2D._UpdateExtension;
begin
  if not Assigned(fSourceBlock) then Exit;
  fSourceBlock.UpdateExtension(Self);
  fBox := fSourceBlock.Box;
end;

procedure TBlock2D.DrawControlPoints(const VT: TTransf2D; const
  Cnv: TDecorativeCanvas;
  const ClipRect2D: TRect2D; const Width: Integer);
var
  TmpPt1: TPoint2D;
begin
  inherited;
  TmpPt1 := TransformPoint2D(fOriginPoint, VT);
  with Point2DToPoint(TmpPt1) do
    DrawPlaceHolder(Cnv, X, Y, Width);
end;

procedure TBlock2D.Draw(VT: TTransf2D; const Cnv:
  TDecorativeCanvas;
  const ClipRect2D: TRect2D; const DrawMode: Integer);
begin
  if not Assigned(fSourceBlock) then Exit;
  fSourceBlock.Draw(VT, Cnv, ClipRect2D, DrawMode);
end;

function TBlock2D.OnMe(PT: TPoint2D; Aperture: TRealType; var
  Distance: TRealType): Integer;
var
  TmpPt: TPoint2D;
begin
  Result := PICK_NOOBJECT;
  if not Assigned(fSourceBlock) then
    Exit;
  Result := inherited OnMe(PT, Aperture, Distance);
  if (Result = PICK_INBBOX) and NearPoint2D(PT,
    fOriginPoint, Aperture, Distance) then
   { the origin of the block was picked. }
    Result := PICK_ONOBJECT
  else
  begin
     { Make Pt in Object coordinates }
    TmpPt := PT;
    Result := fSourceBlock.OnMe(TmpPt, Aperture, Distance);
  end;
end;

// =====================================================================
// TDrawHistory
// =====================================================================

function TDrawHistory.GetCanUndo: Boolean;
begin
  Result := fPosition > 0;
end;

function TDrawHistory.GetCanRedo: Boolean;
begin
  Result := fPosition < Count - 1;
end;

function TDrawHistory.GetIsChanged: Boolean;
begin
  Result := not MD5Match(fCheckSum, fSavedCheckSum) or
    not MD5Match(fOptCheckSum, fSavedOptCheckSum);
end;

constructor TDrawHistory.Create(ADrawing: TDrawing2D);
begin
  inherited Create;
  fDrawing := ADrawing;
  OwnsObjects := True;
  fPosition := 0;
  fCheckSum := MD5String('');
  fSavedCheckSum := fCheckSum;
  fOptCheckSum := fCheckSum;
  fSavedOptCheckSum := fCheckSum;
end;

procedure TDrawHistory.Truncate(Index: Integer);
var
  I: Integer;
begin
  if Index < 0 then
  begin
    Clear;
    Exit;
  end;
  if (Count < 1) then Exit;
  for I := Count - 1 downto Index do Delete(I);
end;

procedure TDrawHistory.Save;
var
  AStream: TMemoryStream;
begin
  Truncate(fPosition + 1);
  AStream := TMemoryStream.Create;
  Add(AStream);
  fPosition := Count - 1;
  fDrawing.SaveObjectsToStream(AStream);
  fCheckSum := MD5Stream(AStream);
end;

procedure TDrawHistory.Undo;
var
  AStream: TMemoryStream;
  OnChangeDrawing0: TOnChangeDrawing;
begin
  if not GetCanUndo then Exit;
  OnChangeDrawing0 := fDrawing.OnChangeDrawing;
  fDrawing.OnChangeDrawing := nil;
  try
    fDrawing.DeleteAllObjects;
    fDrawing.DeleteSavedSourceBlocks;
    Dec(fPosition);
    AStream := Items[fPosition] as TMemoryStream;
    AStream.Position := 0;
    fDrawing.LoadObjectsFromStream(AStream,
      fDrawing.Version);
    fCheckSum := MD5Stream(AStream);
    fDrawing.SelectionClear;
  finally
    fDrawing.OnChangeDrawing := OnChangeDrawing0;
  end;
end;

procedure TDrawHistory.Redo;
var
  AStream: TMemoryStream;
  OnChangeDrawing0: TOnChangeDrawing;
begin
  if not GetCanRedo then Exit;
  OnChangeDrawing0 := fDrawing.OnChangeDrawing;
  fDrawing.OnChangeDrawing := nil;
  try
    fDrawing.DeleteAllObjects;
    fDrawing.DeleteSavedSourceBlocks;
    Inc(fPosition);
    AStream := Items[fPosition] as TMemoryStream;
    AStream.Position := 0;
    fDrawing.LoadObjectsFromStream(AStream,
      fDrawing.Version);
    fCheckSum := MD5Stream(AStream);
    fDrawing.SelectionClear;
  finally
    fDrawing.OnChangeDrawing := OnChangeDrawing0;
  end;
end;

procedure TDrawHistory.Clear;
begin
  inherited Clear;
  fPosition := 0;
  fCheckSum := MD5String('');
  fSavedCheckSum := fCheckSum;
end;

procedure TDrawHistory.SaveCheckSum;
begin
  fSavedCheckSum := fCheckSum;
  fOptCheckSum := fDrawing.OptionsList.GetCheckSum;
  fSavedOptCheckSum := fOptCheckSum;
end;

procedure TDrawHistory.SetPropertiesChanged;
begin
  fOptCheckSum := fDrawing.OptionsList.GetCheckSum;
end;

// =====================================================================
// TDrawing2D
// =====================================================================

constructor TDrawing2D.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetDefaults;
  History := nil;
  OnPasteMetafileFromClipboard := nil;
  OptionsList := TOptionsList.Create;
  FillOptionsList;
end;

procedure TDrawing2D.FillOptionsList;
const
  EOL = #13#10;
begin
  OptionsList.AddString('Caption', @(Caption), 'Caption');
  OptionsList.AddString('Comment', @(Comment), 'Comment');
  OptionsList.AddString('Label', @(FigLabel), 'Label');
  OptionsList.AddRealType('PicScale', @PicScale,
    'Picture scale (mm per unit)');
  OptionsList.AddRealType('Border', @Border,
    'Picture border (mm)');
  OptionsList.AddChoice('TeXFormat',
    @TeXFormat, TeXFormat_Choice,
    'Format for including picture in TeX');
  OptionsList.AddChoice('PdfTeXFormat',
    @PdfTeXFormat, PdfTeXFormat_Choice,
    'Format for including picture in PdfTeX');
  OptionsList.AddRealType('PicUnitLength',
    @PicUnitLength, 'Picture unit length (mm)');
  OptionsList.AddRealType('PicMagnif',
    @PicMagnif,
    'Picture phisical size magnification factor. Use PicScale to represent picture space coordinates in mm. Use PicMagnif to change the meaning of mm for quick rescaling of the picture');
  OptionsList.AddString('IncludePath',
    @(IncludePath),
    'Path to add before \includegraphics file name (like mypictures/)');

  OptionsList.AddRealType('LineWidth', @LineWidthBase,
    'Thin line width (mm)');
  OptionsList.AddRealType('ArrowsSize',
    @(ArrowsSize), 'Arrows size');
  OptionsList.AddRealType('StarsSize',
    @(StarsSize), 'Stars size');
  OptionsList.AddRealType('HatchingStep',
    @HatchingStep, 'Hatching step (mm)');
  OptionsList.AddRealType('HatchingLineWidth',
    @HatchingLineWidth, 'Hatching line width (fraction of LineWidth)');
  OptionsList.AddRealType('DottedSize', @DottedSize,
    'Dotted line size (mm)');
  OptionsList.AddRealType('DashSize', @DashSize,
    'Dashed line size (mm)');
  OptionsList.AddRealType('DefaultFontHeight',
    @(DefaultFontHeight), 'Default font height');
  OptionsList.AddFontName('FontName', @(FontName), 'Font');
  OptionsList.AddRealType('DefaultSymbolSize',
    @DefaultSymbolSize, 'Default symbol size factor ("diameter")');
  OptionsList.AddRealType('MiterLimit',
    @(MiterLimit), 'Miter limit. Used to cut off too long spike miter join'
    + ' could have when the angle between two lines is sharp. If the ratio of miter length'
    + ' (distance between the outer corner and the inner corner of the miter) to'
    + ' line width is greater than miter limit, then bevel join'
    + ' is used instead of miter join. Default value of miter limit is 10.'
    + ' This option is not applicable to TeX-picture and PsTricks formats.');

  OptionsList.AddRealType('TeXMinLine',
    @TeXMinLine, 'TeX minimum line length');
  OptionsList.AddBoolean('TeXCenterFigure',
    @TeXCenterFigure, 'Center TeX figure');
  OptionsList.AddChoice('TeXFigure',
    @TeXFigure, TeXFigure_Choice,
    'TeX figure environment:' + EOL +
    'none - no figure' + EOL +
    'figure - standard {figure} environment' + EOL +
    'floatingfigure - {floatingfigure} from floatflt package'
    + EOL +
    'wrapfigure - {wrapfigure} from wrapfig package');
  OptionsList.AddString('TeXFigurePlacement',
    @(TeXFigurePlacement),
    'The optional argument [placement] determines where LaTeX will try to place your figure. There are four places where LaTeX can possibly put a float:' + EOL
    + 'h (Here) - at the position in the text where the figure environment appears'
    + EOL
    + 't (Top) - at the top of a text page' + EOL
    + 'b (Bottom) - at the bottom of a text page' + EOL +
    'p (Page of floats) - on a separate float page, which is a page containing no text, only floats'
    + EOL +
    'Putting ! as the first argument in the square brackets will encourage LATEX to do what you say, even if the result''s sub-optimal.'
    + EOL +
    ' Example: htbp' + EOL + EOL +
    'For wrapfigure placement is one of  r, l, i, o, R, L, I, O,  for right, left,  inside, outside, (here / FLOAT)'
    + EOL + EOL +
    'The floatingfigure placement option may be either one of the following: r, l, p, or v. The options all overrule any present package option which may be in effect.  The options have the following functions:'
    + EOL +
    'r  Forces the current floating figure to be typset to the right in a paragraph'
    + EOL +
    'l Forces the current floating figure to be typset to the left in a paragraph'
    + EOL +
    'p Forces the current floating figure to be typset to the right in a paragraph if the pagenumber is odd, and to the left if even'
    + EOL +
    'v Applies the package option to the current figure, and if no package option is specified, it forces the current floating figure to be typset to the right in a paragraph if the pagenumber is odd, and to the left if even'
    );
  OptionsList.AddString('TeXFigurePrologue',
    @(TeXFigurePrologue), 'Text to put before float');
  OptionsList.AddString('TeXFigureEpilogue',
    @(TeXFigureEpilogue), 'Text to put after float');
  OptionsList.AddString('TeXPicPrologue',
    @(TeXPicPrologue),
    'Text to put before picture/includegraphics');
  OptionsList.AddString('TeXPicEpilogue',
    @(TeXPicEpilogue),
    'Text to put after picture/includegraphics');

  OptionsList.AddBoolean('MetaPostTeXText',
    @(MetaPostTeXText), 'Use TeX text in MetaPost files');
end;

destructor TDrawing2D.Destroy;
begin
  History.Free;
  OptionsList.Free;
  inherited Destroy;
end;

procedure TDrawing2D.SetDefaults;
begin
  fFileName := Drawing_NewFileName;
  TeXFormat := TeXFormat_Default;
  PdfTeXFormat := PdfTeXFormat_Default;
  fArrowsSize := ArrowsSize_Default;
  fStarsSize := StarsSize_Default;
  DefaultFontHeight := DefaultFontHeight_Default;
  Caption := '';
  FigLabel := '';
  Comment := '';
  {PicWidth := PicWidth_Default;
  PicHeight := PicHeight_Default;}
  PicScale := PicScale_Default;
  PicUnitLength := PicUnitLength_Default;
  HatchingStep := HatchingStep_Default;
  HatchingLineWidth := HatchingLineWidth_Default;
  DottedSize := DottedSize_Default;
  DashSize := DashSize_Default;
  FontName := ''; //FontName_Default;
  TeXMinLine := TeXMinLine_Default;
  TeXCenterFigure := TeXCenterFigure_Default;
  TeXFigure := TeXFigure_Default;
  TeXFigurePlacement := '';
  TeXFigurePrologue := '';
  TeXFigureEpilogue := '';
  TeXPicPrologue := '';
  TeXPicEpilogue := '';
  LineWidthBase := LineWidthBase_Default;
  MiterLimit := 10;
  //FactorMM := 1;
  Border := Border_Default;
  PicMagnif := PicMagnif_Default;
  MetaPostTeXText := MetaPostTeXText_Default;
  IncludePath := IncludePath_Default;
  DefaultSymbolSize := DefaultSymbolSize_Default;
end;

procedure TDrawing2D.Clear;
begin
  if Assigned(History) then History.Clear;
  DeleteAllObjects;
  DeleteSavedSourceBlocks;
  SetDefaults;
  RepaintViewports;
end;

procedure TDrawing2D.SaveObjectsToStream0(const Stream:
  TStream;
  const Iter: TGraphicObjIterator);
var
  TmpObj: TObject2D;
  TmpWord: Word;
  TmpLong, TmpObjPerc: Integer;
begin
  with Stream do
  begin
     { Save the objects. }
    TmpLong := Iter.Count;
    if TmpLong > 0 then
      TmpObjPerc := 100 div TmpLong
    else
      TmpObjPerc := 0;
    Write(TmpLong, SizeOf(TmpLong));
    TmpObj := Iter.First as TObject2D;
    while TmpObj <> nil do
    begin
      if Layers[TmpObj.Layer].Streamable and
        TmpObj.fToBeSaved
        then
      begin
        TmpWord := CADSysFindClassIndex(TmpObj.ClassName);
           { Save the class index. }
        Write(TmpWord, SizeOf(TmpWord));
        TmpObj.SaveToStream(Stream);
        if Assigned(OnSaveProgress) then
          OnSaveProgress(Self, 100 - TmpObjPerc * TmpLong);
        Dec(TmpLong);
      end;
      TmpObj := Iter.Next as TObject2D;
    end;
     { End the list of objects if not all objects were saved. }
    if TmpLong > 0 then
    begin
      TmpWord := 65535;
      Write(TmpWord, SizeOf(TmpWord));
    end;
  end;
end;

procedure TDrawing2D.SaveObjectsToStream(const Stream:
  TStream);
var
  TmpIter: TGraphicObjIterator;
begin
  TmpIter := ObjectList.GetPrivilegedIterator;
  try
    SaveObjectsToStream0(Stream, TmpIter);
  finally
    TmpIter.Free;
  end;
end;

procedure TDrawing2D.SaveSelectionToStream(const Stream:
  TStream);
var
  TmpIter: TGraphicObjIterator;
begin
  TmpIter := Self.fSelectedObjs.GetPrivilegedIterator;
  try
    SaveObjectsToStream0(Stream, TmpIter);
  finally
    TmpIter.Free;
  end;
end;

procedure TDrawing2D.CopySelectionToClipboard;
var
  MemStream: TMemoryStream;
begin
  if Self.fSelectedObjs.Count = 0 then Exit;
  MemStream := TMemoryStream.Create;
  try
    SaveSelectionToStream(MemStream);
    MemStream.Position := 0;
    PutStreamToClipboard(TpXClipboardFormat, True,
      MemStream, MemStream.Size);
  finally
    MemStream.Free;
  end;
end;

procedure TDrawing2D.PasteFromClipboard;
var
  Stream: TMemoryStream;
begin
  if ClipboardHasMetafile then
  begin
    if Assigned(OnPasteMetafileFromClipboard) then
      OnPasteMetafileFromClipboard(Self);
    Exit;
  end;
  if not ClipboardHasTpX then Exit;
  Stream := TMemoryStream.Create;
  try
    GetStreamFromClipboard(TpXClipboardFormat, Stream);
    Stream.Position := 0;
    LoadObjectsFromStream(Stream, Version);
  finally
    Stream.Free;
  end;
end;

{$WARNINGS OFF}

procedure TDrawing2D.LoadObjectsFromStream(const Stream:
  TStream;
  const Version: TCADVersion);
var
  TmpClass: TGraphicObjectClass;
  TmpObj: TGraphicObject;
  TmpLong, TmpObjPerc: Integer;
  TmpWord: Word;
  TmpBlocksIter: TExclusiveGraphicObjIterator;
  OnChangeDrawing0: TOnChangeDrawing;
begin
  OnChangeDrawing0 := fOnChangeDrawing;
  fOnChangeDrawing := nil;
  try
    TmpBlocksIter := SourceBlocksExclusiveIterator;
    with Stream do
    try
      Read(TmpLong, SizeOf(TmpLong));
      if TmpLong > 0 then
        TmpObjPerc := 100 div TmpLong
      else
        TmpObjPerc := 0;
      if TmpLong > 0 then SelectionClear;
      while TmpLong > 0 do
      begin
        { Read the type of object and the length of the record. }
        Read(TmpWord, SizeOf(TmpWord));
        if TmpWord = 65535 then
         { End prematurely. }
          Break;
        Dec(TmpLong);
        { Retrive the class type from the registered classes. }
        try
          TmpClass := CADSysFindClassByIndex(TmpWord);
        except
          on ECADObjClassNotFound do
          begin
            ShowMessage('Object class not found. Object not load');
            Break;
          end;
        end;
        TmpObj := TmpClass.CreateFromStream(Stream,
          Version);
        if Assigned(OnLoadProgress) then
          OnLoadProgress(Self, TmpObjPerc);
        if not (TmpObj is TObject2D) then
        begin
          ShowMessage('Not 2D Object. Object discarded.');
          TmpObj.Free;
          Continue;
        end;
        if TmpObj is TContainer2D then
        try
          TContainer2D(TmpObj).UpdateSourceReferences(TmpBlocksIter);
        except
          on ECADListObjNotFound do
          begin
            ShowMessage('Source block not found. The block will not be loaded');
            TmpObj.Free;
            Continue;
          end;
        end
        else if TmpObj is TBlock2D then
        try
          TBlock2D(TmpObj).UpdateReference(TmpBlocksIter);
        except
          on ECADListObjNotFound do
          begin
            ShowMessage('Source block not found. The block will not be loaded');
            TmpObj.Free;
            Continue;
          end;
        end;
        CurrentLayer := TmpObj.Layer;
        inherited AddObject(-1, TGraphicObject(TmpObj));
        SelectionAdd(TmpObj);
      end;
    finally
      TmpBlocksIter.Free;
    end;
  finally
    fOnChangeDrawing := OnChangeDrawing0;
  end;
  NotifyChanged;
end;
{$WARNINGS ON}

procedure TDrawing2D.SaveBlocksToStream(const Stream:
  TStream;
  const AsLibrary: Boolean);
var
  TmpObj: TSourceBlock2D;
  TmpWord: Word;
  TmpPos, TmpLong: Integer;
  TmpIter: TGraphicObjIterator;
begin
  TmpIter := BlockList.GetPrivilegedIterator;
  with Stream do
  try
    TmpLong := SourceBlocksCount;
    TmpPos := Stream.Position;
    Write(TmpLong, SizeOf(TmpLong));
    TmpObj := TmpIter.First as TSourceBlock2D;
    TmpLong := 0;
    while TmpObj <> nil do
    begin
      if TmpObj.ToBeSaved and
        not (TmpObj.IsLibraryBlock xor AsLibrary) then
      begin
        TmpWord := CADSysFindClassIndex(TmpObj.ClassName);
           { Save the class index. }
        Write(TmpWord, SizeOf(TmpWord));
        TmpObj.SaveToStream(Stream);
        Inc(TmpLong);
      end;
      TmpObj := TmpIter.Next as TSourceBlock2D;
    end;
    Seek(TmpPos, soFromBeginning);
    Write(TmpLong, SizeOf(TmpLong));
    Seek(0, soFromEnd);
  finally
    TmpIter.Free;
  end;
end;

{$WARNINGS OFF}

procedure TDrawing2D.LoadBlocksFromStream(const Stream:
  TStream;
  const Version: TCADVersion);
var
  TmpClass: TGraphicObjectClass;
  TmpObj: TGraphicObject;
  TmpLong: Integer;
  TmpWord: Word;
  TmpBlocksIter: TGraphicObjIterator;
begin
  with Stream do
  begin
     { Load the source blocks. }
    Read(TmpLong, SizeOf(TmpLong));
    while TmpLong > 0 do
    begin
        { Read the type of object and the length of the record. }
      Read(TmpWord, SizeOf(TmpWord));
      Dec(TmpLong);
        { Retrive the class type from the registered classes. }
      try
        TmpClass := CADSysFindClassByIndex(TmpWord);
      except
        on ECADObjClassNotFound do
        begin
          ShowMessage('Object class not found. Object not load');
          Continue;
        end;
      end;
      TmpObj := TmpClass.CreateFromStream(Stream, Version);
      TmpBlocksIter := SourceBlocksIterator;
      try
        TSourceBlock2D(TmpObj).UpdateSourceReferences(TmpBlocksIter);
      except
        on ECADListObjNotFound do
        begin
          ShowMessage('Source block not found. The block will not be loaded');
          TmpObj.Free;
          TmpBlocksIter.Free;
          Continue;
        end;
      end;
      TmpBlocksIter.Free;
      AddSourceBlock(TSourceBlock2D(TmpObj));
    end;
  end;
end;
{$WARNINGS ON}

function TDrawing2D.AddSourceBlock(const Obj:
  TSourceBlock2D):
  TSourceBlock2D;
begin
  Result := Obj;
  inherited AddSourceBlock(-1, Obj);
end;

procedure TDrawing2D.DeleteSourceBlock(const SrcName:
  TSourceBlockName);
var
  TmpSource: TSourceBlock2D;
begin
  TmpSource := TSourceBlock2D(FindSourceBlock(SrcName));
  if TmpSource.NumOfReferences > 0 then
    raise
      ECADSysException.Create('TDrawing2D.DeleteSourceBlock: Remove the references before the source');
  DeleteSourceBlockByID(TmpSource.ID);
end;

function TDrawing2D.GetSourceBlock(const ID: Integer):
  TSourceBlock2D;
begin
  Result := inherited GetSourceBlock(ID) as TSourceBlock2D;
end;

function TDrawing2D.FindSourceBlock(const SrcName:
  TSourceBlockName): TSourceBlock2D;
var
  TmpIter: TGraphicObjIterator;
begin
  TmpIter := SourceBlocksIterator;
  try
    Result := TmpIter.First as TSourceBlock2D;
    while Result <> nil do
    begin
      if SrcName = Result.Name then
        Exit;
      Result := TmpIter.Next as TSourceBlock2D;
    end;
  finally
    TmpIter.Free;
  end;
  raise
    ECADListObjNotFound.Create(Format('TDrawing2D.FindSourceBlock: Source block %s not found', [SrcName]));
end;

function TDrawing2D.BlockObjects(const SrcName:
  TSourceBlockName;
  const Objs: TGraphicObjIterator): TSourceBlock2D;
var
  TmpObj: TObject2D;
begin
  Result := TSourceBlock2D.CreateSpec(0, SrcName, [nil]);
  try
    TmpObj := Objs.First as TObject2D;
    while TmpObj <> nil do
    begin
      Result.Objects.Add(TmpObj);
      TmpObj := Objs.Next as TObject2D;
    end;
    AddSourceBlock(Result);
  except
    Result.Free;
    Result := nil;
  end;
end;

procedure TDrawing2D.DeleteSavedSourceBlocks;
var
  TmpObj: TGraphicObject;
  TmpIter: TExclusiveGraphicObjIterator;
begin
  TmpIter := SourceBlocksExclusiveIterator;
  try
    TmpObj := TmpIter.First;
    while Assigned(TmpObj) do
      if TSourceBlock2D(TmpObj).ToBeSaved and not
        TSourceBlock2D(TmpObj).IsLibraryBlock then
      try
        TmpIter.DeleteCurrent;
        TmpObj := TmpIter.Current;
      except
        TmpObj := TmpIter.Next;
      end
      else
        TmpObj := TmpIter.Next;
  finally
    TmpIter.Free;
  end;
end;

procedure TDrawing2D.DeleteLibrarySourceBlocks;
var
  TmpObj: TGraphicObject;
  TmpIter: TExclusiveGraphicObjIterator;
begin
  TmpIter := SourceBlocksExclusiveIterator;
  try
    TmpObj := TmpIter.First;
    while Assigned(TmpObj) do
      if TSourceBlock2D(TmpObj).IsLibraryBlock then
      try
        TmpIter.DeleteCurrent;
        TmpObj := TmpIter.Current;
      except
        TmpObj := TmpIter.Next;
      end
      else
        TmpObj := TmpIter.Next;
  finally
    TmpIter.Free;
  end;
end;

function TDrawing2D.AddObject(const ID: Integer; const Obj:
  TObject2D): TObject2D;
begin
  Result := Obj;
  inherited AddObject(ID, TGraphicObject(Obj));
end;

function TDrawing2D.InsertObject(const ID, IDInsertPoint:
  Integer; const Obj: TObject2D): TObject2D;
begin
  Result := Obj;
  inherited InsertObject(ID, IDInsertPoint,
    TGraphicObject(Obj));
end;

function TDrawing2D.AddBlock(const ID: Integer; const
  SrcName:
  TSourceBlockName): TObject2D;
var
  Tmp: TBlock2D;
  TmpSource: TSourceBlock2D;
begin
  TmpSource := FindSourceBlock(SrcName);
  Tmp := TBlock2D.CreateSpec(ID, TmpSource);
  try
    AddObject(ID, Tmp);
    Result := Tmp;
  except
    Tmp.Free;
    Result := nil;
  end;
end;

function TDrawing2D.GetObject(const ID: Integer): TObject2D;
begin
  Result := inherited GetObject(ID) as TObject2D;
end;

procedure TDrawing2D.TransformObjects(
  const ListOfObj: array of Integer; const T: TTransf2D);
var
  Cont: Integer;
  Tmp: TObject2D;
  TmpIter: TExclusiveGraphicObjIterator;
begin
  if High(ListOfObj) < 0 then Exit;
  TmpIter := ObjectsExclusiveIterator;
  try
    if ListOfObj[Low(ListOfObj)] < 0 then
    begin
       { Apply trasform to all objects. }
      Tmp := TmpIter.First as TObject2D;
      while Tmp <> nil do
      begin
        Tmp.TransForm(T);
        Tmp := TmpIter.Next as TObject2D;
      end;
    end
    else
      for Cont := Low(ListOfObj) to High(ListOfObj) do
      begin
        try
          Tmp := TObject2D(TmpIter.Search(ListOfObj[Cont]));
        except
          on Exception do
            raise
              ECADListObjNotFound.Create('TDrawing2D.TransformObjects: Object not found');
        end;
        if Tmp <> nil then
        begin
          Tmp.TransForm(T);
        end;
      end;
  finally
    TmpIter.Free;
  end;
  if RepaintAfterTransform then RepaintViewports;
  NotifyChanged;
end;

procedure TDrawing2D.ScaleAll(const P: TPoint2D; ScaleX,
  ScaleY:
  TRealType);
var
  Rect: TRect2D;
  T: TTransf2D;
begin
  Rect := GetExtension;
  T := Translate2D(-Rect.Left, -Rect.Bottom);
  T := MultiplyTransform2D(T, Scale2D(ScaleX, ScaleY));
  T := MultiplyTransform2D(T, Translate2D(P.X, P.Y));
  TransformObjects([-1], T);
end;

function TDrawing2D.ScaleStandard(ScaleStandardMaxWidth,
  ScaleStandardMaxHeight: TRealType): TTransf2D;
var
  Rect: TRect2D;
  ScaleX, ScaleY, Scale: TRealType;
begin
  Rect := GetExtension;
  if Rect.Top <= Rect.Bottom then Exit;
  Result := Translate2D(-Rect.Left, -Rect.Bottom);
  ScaleX := ScaleStandardMaxWidth / (Rect.Right - Rect.Left);
  ScaleY := ScaleStandardMaxHeight / (Rect.Top - Rect.Bottom);
  Scale := Min(ScaleX, ScaleY) / Self.PicScale;
  Result := MultiplyTransform2D(Result, Scale2D(Scale, Scale));
  TransformObjects([-1], Result);
end;

procedure TDrawing2D.ScalePhysical(const S: TRealType);
begin
//  fDrawing2D.PicScale := fDrawing2D.PicScale * Magnif;
  Border := Border * S;
  if not ScaleLineWidth then
    LineWidthBase := LineWidthBase * S;
  HatchingStep := HatchingStep * S;
  DottedSize := DottedSize * S;
  DashSize := DashSize * S;
  History.SetPropertiesChanged;
end;

procedure TDrawing2D.RedrawObject(const Obj: TObject2D);
begin
  inherited RedrawObject(Obj);
end;

procedure TDrawing2D.MakeGrayscale;
var
  Obj: TGraphicObject;
  Iter: TGraphicObjIterator;
begin
  Iter := ObjectsIterator;
  try
    Obj := Iter.First;
    while Assigned(Obj) do
    begin
      if Obj is TPrimitive2D then
        with Obj as TPrimitive2D do
        begin
          if LineColor <> clDefault then LineColor := GrayScale(LineColor);
          if HatchColor <> clDefault then HatchColor := GrayScale(HatchColor);
          if FillColor <> clDefault then FillColor := GrayScale(FillColor);
        end;
      Obj := Iter.Next;
    end;
  finally
    Iter.Free;
  end;
  NotifyChanged;
end;
//TSY:

function TDrawing2D.PickObject(const PT: TPoint2D;
  const Aperture: TRealType;
  const VisualRect: TRect2D; const DrawMode: Integer;
  const FirstFound: Boolean; var NPoint: Integer): TObject2D;
var
  TmpObj: TObject2D;
  TmpNPoint: Integer;
begin
  Result := Self.fSelectedObjs.PickObject(PT, Self, Aperture, VisualRect,
    DrawMode, FirstFound, NPoint);
  if NPoint >= 0 then Exit;
  TmpObj := Self.fListOfObjects.PickObject(PT, Self, Aperture, VisualRect,
    DrawMode, FirstFound, TmpNPoint);
  if TmpObj = nil then Exit;
  if (Result = nil) or (NPoint < TmpNPoint)
    or ((NPoint = TmpNPoint) and (Result.ID < TmpObj.ID)) then
  begin
    Result := TmpObj;
    NPoint := TmpNPoint;
  end;
end;

//TSY:

function GetExtension0(Drawing2D: TDrawing2D;
  Iter: TGraphicObjIterator): TRect2D;
var
  Tmp: TObject2D;
begin
  Result := Rect2D(MaxCoord, MaxCoord, MinCoord, MinCoord);
  Tmp := Iter.First as TObject2D;
  while Tmp <> nil do
  begin
    if Drawing2D.Layers[Tmp.Layer].fVisible then
    begin
      try
        Tmp.UpdateExtension(Drawing2D);
      finally
      end;
          { Set the new extension if necessary. }
      if Tmp.Box.Left < Result.Left then
        Result.Left := Tmp.Box.Left;
      if Tmp.Box.Right > Result.Right then
        Result.Right := Tmp.Box.Right;
      if Tmp.Box.Bottom < Result.Bottom then
        Result.Bottom := Tmp.Box.Bottom;
      if Tmp.Box.Top > Result.Top then
        Result.Top := Tmp.Box.Top;
    end;
    Tmp := Iter.Next as TObject2D;
  end;
end;

function TDrawing2D.GetExtension: TRect2D;
var
  TmpIter: TGraphicObjIterator;
begin
  if ObjectsCount = 0 then
  begin
    Result := Rect2D(0, 0, 0, 0);
    Exit;
  end;
  TmpIter := ObjectsIterator;
  try
    Result := GetExtension0(Self, TmpIter);
  finally
    TmpIter.Free;
  end;
end;

// =====================================================================
// TCADViewport2D
// =====================================================================

procedure TCADViewport2D.SetDrawing(Cad: TDrawing);
begin
  if (Cad <> fDrawing2D) then
  begin
    inherited SetDrawing(Cad);
    fDrawing2D := Cad as TDrawing2D;
  end;
end;

procedure TCADViewport2D.SetDrawing2D(CAD2D: TDrawing2D);
begin
  SetDrawing(CAD2D);
end;

constructor TCADViewport2D.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fPickFilter := TObject2D;
  fImageList := nil;
  fBrushBitmap := TBitmap.Create;
end;

destructor TCADViewport2D.Destroy;
begin
  fBrushBitmap.Free;
  inherited Destroy;
end;

procedure TCADViewport2D.DrawObject(const Obj:
  TGraphicObject;
  const Cnv: TDecorativeCanvas; const ClipRect2D: TRect2D);
var
  BitmapIndex: Integer;
begin
  if not TObject2D(Obj).IsVisible(VisualRect, DrawMode) then
    Exit;
  with Obj as TObject2D do
  begin
    if (Drawing.Layers.SetCanvas(Cnv, Layer)) then
    begin
    //TSY:
      Cnv.Canvas.Pen.Style := psSolid;
      Cnv.Canvas.Pen.Color := clBlack;
      //Cnv.Canvas.Pen.Width := 1;
      //Cnv.Canvas.Brush.Style := bsSolid;
      if (Obj is TPrimitive2D) then
      begin
        if (Obj as TPrimitive2D).LineStyle = liNone
          then Cnv.Canvas.Pen.Width := 0
        else
          Cnv.Canvas.Pen.Width := Round((Obj as TPrimitive2D).LineWidth);
        case (Obj as TPrimitive2D).LineStyle of
          liDotted:
            begin
              Cnv.Canvas.Pen.Style := psDot;
              Cnv.DecorativePen.SetPenStyle('111000');
            end;
          liDashed:
            begin
              Cnv.Canvas.Pen.Style := psDash;
              Cnv.DecorativePen.SetPenStyle(
                '111111111111111111100000000000');
            end;
        end;
        if {ImageList = nil}  True then
        begin
          case (Obj as TPrimitive2D).Hatching of
            haNone: Cnv.Canvas.Brush.Style := bsClear;
            haHorizontal: Cnv.Canvas.Brush.Style :=
              bsHorizontal;
            haVertical: Cnv.Canvas.Brush.Style :=
              bsVertical;
            haFDiagonal: Cnv.Canvas.Brush.Style :=
              bsFDiagonal;
            haBDiagonal: Cnv.Canvas.Brush.Style :=
              bsBDiagonal;
            haCross: Cnv.Canvas.Brush.Style := bsCross;
            haDiagCross: Cnv.Canvas.Brush.Style :=
              bsDiagCross;
          end;
          Cnv.Canvas.Brush.Color := clGray;
        end
        else
        begin
          case (Obj as TPrimitive2D).Hatching of
            haNone: Cnv.Canvas.Brush.Style := bsClear;
            haHorizontal: BitmapIndex := 0;
            haVertical: BitmapIndex := 1;
            haFDiagonal: BitmapIndex := 2;
            haBDiagonal: BitmapIndex := 3;
            haCross: BitmapIndex := 4;
            haDiagCross: BitmapIndex := 5;
          end;
          if (Obj as TPrimitive2D).Hatching = haNone
            then Cnv.Canvas.Brush.Bitmap := nil
          else
          begin
            //ImageList.GetBitmap(BitmapIndex,              Cnv.Canvas.Brush.Bitmap);
            fBrushBitmap.Free;
            fBrushBitmap := TBitmap.Create;
            ImageList.GetBitmap(BitmapIndex, fBrushBitmap);
            Cnv.Canvas.Brush.Bitmap := fBrushBitmap;
          end;
        end;
      end;
      Draw(ViewportToScreenTransform, Cnv, ClipRect2D,
        DrawMode);
    //TSY: removed
      {if HasControlPoints then
      begin
        Cnv.Canvas.Pen.Color := fControlPointsPenColor;
        Cnv.Canvas.Pen.Width := 1;
        Cnv.Canvas.Brush.Style := bsSolid;
        Cnv.Canvas.Brush.Color := ControlPointsColor;
        DrawControlPoints(ViewportToScreenTransform, Cnv,
          ClipRect2D, ControlPointsWidth);
      end;}
    end;
  end;
end;

procedure TCADViewport2D.DrawObjectControlPoints(const Obj:
  TGraphicObject; const Cnv: TDecorativeCanvas;
  const ClipRect2D: TRect2D);
begin
  if not TObject2D(Obj).IsVisible(VisualRect, DrawMode) then
    Exit;
  with Obj as TObject2D do
  begin
        //Cnv.Canvas.Pen.Color := fControlPointsPenColor;
    Cnv.Canvas.Pen.Color := clBlack;
    Cnv.Canvas.Pen.Width := 1;
    Cnv.Canvas.Brush.Style := bsSolid;
        //Cnv.Canvas.Brush.Color := ControlPointsColor;
    Cnv.Canvas.Brush.Color := clSilver;
    DrawControlPoints(ViewportToScreenTransform, Cnv,
      ClipRect2D, ControlPointsWidth);
  end;
end;

procedure TCADViewport2D.DrawObjectWithRubber(const Obj:
  TGraphicObject; const Cnv: TDecorativeCanvas; const
  ClipRect2D: TRect2D);
begin
  //TSY:
  if Obj = nil then Exit;
  if not TObject2D(Obj).IsVisible(VisualRect, DrawMode) then
    Exit;
  with Obj as TObject2D do
  try
    Cnv.Canvas.Pen.Assign(RubberPen);
    Cnv.Canvas.Brush.Color := RubberPen.Color;
    //Cnv.Canvas.Brush.Style := bsSolid;
    Cnv.Canvas.Brush.Style := bsHorizontal;
    Draw(ViewportToScreenTransform, Cnv, ClipRect2D,
      DrawMode or DRAWMODE_OutlineOnly);
    {if ShowControlPoints then
    begin
      Cnv.Canvas.Pen.Assign(RubberPen);
      Cnv.Canvas.Pen.Color := fControlPointsPenColor;
      Cnv.Canvas.Pen.Width := 1;
      Cnv.Canvas.Brush.Color := ControlPointsColor;
      DrawControlPoints(ViewportToScreenTransform, Cnv,
        ClipRect2D, ControlPointsWidth);
    end;}
  finally
  end;
end;

procedure TCADViewport2D.DrawObject2D(const Obj: TObject2D;
  const
  CtrlPts: Boolean);
var
  TmpFlag: Boolean;
begin
  if not Assigned(fDrawing2D) then Exit;
  TmpFlag := ShowControlPoints;
  ShowControlPoints := ShowControlPoints or CtrlPts;
  try
    DrawObject(Obj, OffScreenCanvas,
      RectToRect2D(ClientRect));
    DrawObject(Obj, OnScreenCanvas,
      RectToRect2D(ClientRect));
  finally
    ShowControlPoints := TmpFlag;
  end;
end;

procedure TCADViewport2D.DrawObject2DWithRubber(const Obj:
  TObject2D; const CtrlPts: Boolean);
var
  TmpFlag: Boolean;
begin
  if not Assigned(fDrawing2D) then Exit;
  //TSY:
  if not Assigned(Obj) then Exit;
  TmpFlag := ShowControlPoints;
  ShowControlPoints := ShowControlPoints or CtrlPts;
  try
    DrawObjectWithRubber(Obj, OnScreenCanvas,
      RectToRect2D(ClientRect));
  finally
    ShowControlPoints := TmpFlag;
  end;
end;

procedure TCADViewport2D.CopyRectToCanvas(CADRect: TRect2D;
  const CanvasRect: TRect;
  const Cnv: TCanvas;
  const Mode: TCanvasCopyMode);
var
  Tmp: TObject2D;
  TmpTransform: TTransf2D;
  TmpFlag: Boolean;
  TmpIter: TGraphicObjIterator;
  TmpCanvas: TDecorativeCanvas;
  TmpClipRect: TRect2D;
begin
  StopRepaint;
  if not Assigned(fDrawing2D) then
    Exit;
  TmpCanvas := TDecorativeCanvas.Create(Cnv);
  if (ViewportObjects <> nil) then
    TmpIter := ViewportObjects.GetIterator
  else
    TmpIter := fDrawing2D.ObjectsIterator;
  try
    case Mode of
      cmNone: TmpTransform := GetVisualTransform2D(CADRect,
          CanvasRect, 0);
      cmAspect: TmpTransform :=
        GetVisualTransform2D(CADRect,
          CanvasRect, AspectRatio);
    else
      TmpTransform := ViewportToScreenTransform;
    end;
    Tmp := TObject2D(TmpIter.First);
    TmpFlag := ShowControlPoints;
    ShowControlPoints := False;
    //TST:
    //TmpClipRect := RectToRect2D(ClientRect);
    TmpClipRect := CADRect;
    while Tmp <> nil do
    begin
      if Tmp.IsVisible(CADRect, DrawMode) then
      begin
        fDrawing2D.Layers.SetCanvas(TmpCanvas, Tmp.Layer);
        Tmp.Draw(TmpTransform, TmpCanvas, TmpClipRect,
          DrawMode);
      end;
      Tmp := TObject2D(TmpIter.Next);
    end;
    ShowControlPoints := TmpFlag;
  finally
    TmpIter.Free;
    TmpCanvas.Free;
  end;
end;

function TCADViewport2D.GetCopyRectViewportToScreen(CADRect:
  TRect2D;
  const CanvasRect: TRect;
  const Mode: TCanvasCopyMode): TTransf2D;
begin
  case Mode of
    cmNone: Result := GetVisualTransform2D(CADRect,
        CanvasRect,
        0);
    cmAspect: Result := GetVisualTransform2D(CADRect,
        CanvasRect, AspectRatio);
  else
    Result := ViewportToScreenTransform;
  end;
end;

procedure TCADViewport2D.ZoomToExtension;
var
  NewWindow2D: TRect2D;
  Marg: TRealType;
begin
  if not Assigned(fDrawing2D) then
    Exit;
  StopRepaint;
  if Drawing2D.ObjectsCount = 0 then
  begin
    Repaint;
    Exit;
  end;
  NewWindow2D := fDrawing2D.DrawingExtension;
  Marg := Abs(NewWindow2D.Right - NewWindow2D.Left) / 20;
  Marg := MaxValue([Marg, Abs(NewWindow2D.Top -
      NewWindow2D.Bottom) / 20]);
  NewWindow2D.Left := NewWindow2D.Left - Marg;
  NewWindow2D.Right := NewWindow2D.Right + Marg;
  NewWindow2D.Bottom := NewWindow2D.Bottom - Marg;
  NewWindow2D.Top := NewWindow2D.Top + Marg;
  ZoomWindow(NewWindow2D);
end;

procedure TCADViewport2D.GroupObjects(const ResultLst:
  TGraphicObjList;
  Frm: TRect2D;
  const Mode: TGroupMode;
  const RemoveFromCAD: Boolean);
var
  Tmp: TObject2D;
  TmpObjectsIter: TExclusiveGraphicObjIterator;
begin
  if not Assigned(fDrawing2D) or Drawing.HasIterators then
    Exit;
  StopRepaint;
  Frm := ReorderRect2D(Frm);
  ResultLst.FreeOnClear := RemoveFromCAD;
  TmpObjectsIter := fDrawing2D.ObjectsExclusiveIterator;
  try
    Tmp := TmpObjectsIter.First as TObject2D;
    while Tmp <> nil do
      with (Drawing.Layers[Tmp.Layer]) do
      begin
        if Active and Visible and (Tmp.Enabled) and (Tmp is
          fPickFilter) and Tmp.IsVisible(VisualRect,
          DrawMode)
          then
        begin
          if (Mode = gmAllInside) and
            IsBoxAllInBox2D(Tmp.Box,
            Frm) then
            { The object is in the frame. }
          begin
            ResultLst.Add(Tmp);
            if RemoveFromCAD then
            begin
              TmpObjectsIter.RemoveCurrent;
              Tmp := TObject2D(TmpObjectsIter.Current);
              Continue;
            end;
          end
          else if (Mode = gmCrossFrame) and
            IsBoxInBox2D(Tmp.Box, Frm) then
          begin
            ResultLst.Add(Tmp);
            if RemoveFromCAD then
            begin
              TmpObjectsIter.RemoveCurrent;
              Tmp := TObject2D(TmpObjectsIter.Current);
              Continue;
            end;
          end;
        end;
        Tmp := TmpObjectsIter.Next as TObject2D;
      end;
  finally
    TmpObjectsIter.Free;
  end;
end;

function TCADViewport2D.PickObject(PT: TPoint2D; Aperture:
  Word;
  FirstFound: Boolean; var NPoint: Integer): TObject2D;
var
  TmpNPoint: Integer;
  Tmp: TObject2D;
  WAperture, MinDist, Distance: TRealType;
  TmpIter: TExclusiveGraphicObjIterator;
begin
  Result := nil;
  if (not Assigned(fDrawing2D)) and (not
    Assigned(ViewportObjects)) then
    Exit;
  if Drawing.HasIterators then
    Exit;
  if (ViewportObjects <> nil) then
    TmpIter := ViewportObjects.GetExclusiveIterator
  else
    TmpIter := fDrawing2D.ObjectsExclusiveIterator;
  StopRepaint;
  try
    // Trasforma l'apertura in coordinate mondo.
    WAperture := GetPixelAperture.X * Aperture;
    MinDist := WAperture;
    NPoint := PICK_NOOBJECT;
    Tmp := TmpIter.Current as TObject2D;
    while Tmp <> nil do
      with (Drawing.Layers[Tmp.Layer]) do
      begin
        if Active and Visible and (Tmp is fPickFilter) and
          Tmp.IsVisible(VisualRect, DrawMode) then
        begin
          TmpNPoint := Tmp.OnMe(PT, WAperture, Distance);
          if (TmpNPoint >= NPoint) and (Distance <= MinDist)
            then
          begin
            Result := Tmp;
            NPoint := TmpNPoint;
            MinDist := Distance;
            if FirstFound then
              Break;
          end;
        end;
        Tmp := TmpIter.Next as TObject2D;
      end;
  finally
    TmpIter.Free;
  end;
end;

function TCADViewport2D.PickListOfObjects(const
  PickedObjects:
  TList; PT: TPoint2D; Aperture: Word): Integer;
var
  Tmp: TObject2D;
  WAperture, Distance: TRealType;
  TmpIter: TExclusiveGraphicObjIterator;
begin
  Result := 0;
  if (not Assigned(fDrawing2D)) and (not
    Assigned(ViewportObjects)) then
    Exit;
  if Drawing.HasIterators then
    Exit;
  if (ViewportObjects <> nil) then
    TmpIter := ViewportObjects.GetExclusiveIterator
  else
    TmpIter := fDrawing2D.ObjectsExclusiveIterator;
  StopRepaint;
  try
    // Trasforma l'apertura in coordinate mondo.
    WAperture := GetPixelAperture.X * Aperture;
    Tmp := TmpIter.Current as TObject2D;
    while Tmp <> nil do
      with (Drawing.Layers[Tmp.Layer]) do
      begin
        if Active and Visible and (Tmp is fPickFilter) and
          Tmp.IsVisible(VisualRect, DrawMode) then
        begin
          if Tmp.OnMe(PT, WAperture, Distance) >
            PICK_NOOBJECT
            then
          begin
            PickedObjects.Add(Tmp);
            Inc(Result);
          end;
        end;
        Tmp := TmpIter.Next as TObject2D;
      end;
  finally
    TmpIter.Free;
  end;
end;

function TCADViewport2D.PickObjectWithSelection(const PT: TPoint2D;
  const Aperture: Word;
  const FirstFound: Boolean; var NPoint: Integer): TObject2D;
begin
  Result := nil;
  if not Assigned(fDrawing2D) then Exit;
  Result := fDrawing2D.PickObject(PT, GetPixelAperture.X * Aperture,
    VisualRect, DrawMode, FirstFound, NPoint);
end;

function TCADViewport2D.WorldToObject(const Obj: TObject2D;
  WPt:
  TPoint2D): TPoint2D;
begin
  Result := CartesianPoint2D(WPt);
end;

function TCADViewport2D.ObjectToWorld(const Obj: TObject2D;
  Opt:
  TPoint2D): TPoint2D;
begin
  Opt := CartesianPoint2D(Opt);
  Result := Opt;
end;

procedure TCADViewport2D.MouseMove(Shift: TShiftState; X, Y:
  Integer);
var
  Pos2D: TPoint2D;
begin
  Pos2D := ScreenToViewport(Point2D(X, Y));
  if (not DisableMouseEvents) and Assigned(fOnMouseMove2D)
    then
    fOnMouseMove2D(Self, Shift, Pos2D.X, Pos2D.Y, X, Y);
  inherited MouseMove(Shift, X, Y);
end;

procedure TCADViewport2D.MouseDown(Button: TMouseButton;
  Shift:
  TShiftState;
  X, Y: Integer);
var
  Pos2D: TPoint2D;
begin
  if (not DisableMouseEvents) and Assigned(fOnMouseDown2D)
    then
  begin
    Pos2D := ScreenToViewport(Point2D(X, Y));
    fOnMouseDown2D(Self, Button, Shift, Pos2D.X, Pos2D.Y, X,
      Y);
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TCADViewport2D.MouseUp(Button: TMouseButton;
  Shift:
  TShiftState;
  X, Y: Integer);
var
  Pos2D: TPoint2D;
begin
  if (not DisableMouseEvents) and Assigned(fOnMouseUp2D)
    then
  begin
    Pos2D := ScreenToViewport(Point2D(X, Y));
    fOnMouseUp2D(Self, Button, Shift, Pos2D.X, Pos2D.Y, X,
      Y);
  end;
  inherited MouseUp(Button, Shift, X, Y);
end;

function TCADViewport2D.DoMouseWheel(Shift: TShiftState;
  WheelDelta: Integer;
  MousePos: TPoint): Boolean;
var
  IsNeg: Boolean;
begin
  Result := False;
  if (not DisableMouseEvents) and Assigned(FOnMouseWheel) then
    FOnMouseWheel(Self, Shift, WheelDelta, MousePos, Result);
end;

procedure TCADViewport2D.CMMouseWheel(var Message:
  TCMMouseWheel);
begin
  with Message do
  begin
    Result := 0;
    if DoMouseWheel(ShiftState, WheelDelta,
      SmallPointToPoint(Pos)) then
      Message.Result := 1
    else if Parent <> nil then
      with TMessage(Message) do
        Result := Parent.Perform(CM_MOUSEWHEEL, WParam, LParam);
  end;
end;

function TCADViewport2D.BuildViewportTransform(var ViewWin:
  TRect2D;
  const ScreenWin: TRect;
  const AspectRatio: TRealType): TTransf2D;
begin
  Result := GetVisualTransform2D(ViewWin, ScreenWin,
    AspectRatio);
end;

// =====================================================================
// TCADPrgParam
// =====================================================================

constructor TCADPrgParam.Create(AfterS: TCADStateClass);
begin
  inherited Create;

  fAfterState := AfterS;
end;

// =====================================================================
// TCADState
// =====================================================================

constructor TCADState.Create(const CADPrg: TCADPrg; const
  StateParam: TCADPrgParam; var NextState: TCADStateClass);
begin
  inherited Create;
  fCAD := CADPrg;
  fParam := StateParam;
  fCanBeSuspended := True;
  Description := '';
  NextState := nil;
end;

procedure TCADState.SetDescription(D: string);
begin
  fDescription := D;
  if Assigned(fCAD) and Assigned(fCAD.fOnDescriptionChanged)
    then
    fCAD.fOnDescriptionChanged(Self);
end;

function TCADState.OnEvent(Event: TCADPrgEvent;
  MouseButton: TCS4MouseButton;
  Shift: TShiftState;
  Key: Word;
  var NextState: TCADStateClass): Boolean;
begin
  Result := False;
end;

procedure TCADState.OnStop;
begin
  Param.Free;
  Param := nil;
end;

procedure TCADState.OnResume;
begin
end;

procedure TCADState.OnSuspend;
begin

end;

function TCADState.SelectedObjs: TGraphicObjList;
begin
  Result := CADPrg.Viewport.Drawing.SelectedObjects;
end;

function TCADState.SelectionFilter: TObject2DClass;
begin
  Result := CADPrg.Viewport.Drawing.SelectionFilter;
end;

// =====================================================================
// TCADIdleState.
// =====================================================================

constructor TCADIdleState.Create(const CADPrg: TCADPrg; const
  StateParam: TCADPrgParam; var NextState: TCADStateClass);
begin
  inherited Create(CADPrg, StateParam, NextState);
  if Param <> nil then
    raise
      Exception.Create('TCADIdleState.Create: Non all objects were destroied');
  NextState := nil;
end;

// =====================================================================
// TCADPrg
// =====================================================================

procedure TCADPrg.SetLinkedViewport(V: TCADViewport);
begin
  if V = fLinkedViewport then
    Exit;
  { Subclassing component. Charles F. I. Savage gave my this idea from its
    TCADViewport subclassing. Thanks Charles. }
  if Assigned(fNewWndProc) then
  begin
    if not (csDestroying in fLinkedViewport.ComponentState)
      then
      SetWindowLong(fLinkedViewport.Handle,
        Integer(fOldWndProc));
    Classes.FreeObjectInstance(fNewWndProc);
    fNewWndProc := nil;
  end;
  // Reassign the old on paint.
  if Assigned(fLinkedViewport) then
  begin
    fLinkedViewport.OnPaint := fOldOnPaint;
    if fShowCursorCross then
      HideCursorCross;
  end;
  fLinkedViewport := V;
  if Assigned(V) then
  begin
    V.FreeNotification(Self);
    fNewWndProc := Classes.MakeObjectInstance(SubclassedWinProc);
    fOldWndProc := Pointer(SetWindowLong(V.Handle,
      Integer(fNewWndProc)));
     // Assign the new OnPaint because it is called not only by window msgs.
    fOldOnPaint := V.OnPaint;
    V.OnPaint := ViewOnPaint;
    if fShowCursorCross then
      HideCursorCross;
  end;
end;

procedure TCADPrg.SetDefaultState(DefState: TCADStateClass);
var
  TmpState: TCADStateClass;
begin
  if CurrentState is fDefaultState then
  begin
    CurrentState.OnStop;
    CurrentState.Free;
    fCurrentState := nil;
    fDefaultState := DefState;
    fCurrentState := fDefaultState.Create(Self, nil,
      TmpState);
  end
  else
    fDefaultState := DefState;
end;

procedure TCADPrg.SendEvent(Event: TCADPrgEvent;
  MouseButton:
  TCS4MouseButton;
  Shift: TShiftState; Key: Word);
var
  NextState: TCADStateClass;
  Res, TmpBool: Boolean;
  LastParam: TCADPrgParam;
  LastState: TClass;
begin
  if fIgnoreEvents then
    Exit;
  NextState := nil;
  Res := fCurrentState.OnEvent(Event, MouseButton, Shift,
    Key,
    NextState);
  if Res then
  begin
    if Assigned(fOnExState) then
      fOnExState(Self, fCurrentState);
    repeat
      LastParam := fCurrentState.fParam;
      LastState := fCurrentState.ClassType;
      if (NextState = fDefaultState) or (NextState = nil)
        then
      begin
        if Assigned(fOnEndOperation) then
          fOnEndOperation(Self, fCurrentOperation,
            fCurrentState.fParam);
        GoToDefaultState(LastState, LastParam);
        Break;
      end;
      TmpBool := fCurrentState.CanBeSuspended;
      fCurrentState.Free;
      fCurrentState := nil;
      try
        fCurrentState := NextState.Create(Self, LastParam,
          NextState);
        fCurrentState.CanBeSuspended := TmpBool;
      except
        Reset;
        Break;
      end;
      if Assigned(fOnEntState) then
        fOnEntState(Self, fCurrentState);
    until not Assigned(NextState);
  end;
end;

procedure TCADPrg.GoToDefaultState(const LastState: TClass;
  const
  LastParam: TCADPrgParam);
var
  TmpState: TCADStateClass;
begin
  if not Assigned(fLinkedViewport) then Exit;
  if not Assigned(fCurrentState) then
  begin
    fCurrentState := fDefaultState.Create(Self, nil,
      TmpState);
    Exit;
  end;
  if fIsSuspended then
  begin
    fCurrentState.Free;
    fCurrentState := nil;
    fCurrentState := fSuspendedState;
    fSuspendedState := nil;
    fCurrentOperation := fSuspendedOperation;
    fSuspendedOperation := nil;
     // Force the OnDescriptionChanged event.
    fCurrentState.Description := fCurrentState.Description;
    fIsSuspended := False;
    if fShowCursorCross then
      HideCursorCross;
    if fMustRepaint and not IsBoxInBox2D(Rect2D(0.0, 0.0,
      0.0,
      0.0), fRepaintRect) then
      fLinkedViewport.RepaintRect(fRepaintRect)
    else if fMustRepaint then
      fLinkedViewport.Repaint
    else if fRefreshAfterOp then
      fLinkedViewport.Refresh;
    if fShowCursorCross then
      DrawCursorCross;
    fMustRepaint := False;
    fCurrentState.OnResume(LastState, LastParam);
    if Assigned(LastParam) and (LastParam <>
      fCurrentState.fParam) then
      LastParam.Free;
    Exit;
  end;
  fIsBusy := False;
  if Assigned(fCurrentState.fParam) then
    fCurrentState.fParam.Free;
  fCurrentState.Free;
  fCurrentState := nil;
  fCurrentOperation := nil;
  if fShowCursorCross then
    HideCursorCross;
  if fMustRepaint and not IsBoxInBox2D(Rect2D(0.0, 0.0, 0.0,
    0.0), fRepaintRect) then
    fLinkedViewport.RepaintRect(fRepaintRect)
  else if fMustRepaint then
    fLinkedViewport.Repaint
  else if fRefreshAfterOp then
    fLinkedViewport.Refresh;
  if fShowCursorCross then
    DrawCursorCross;
  fMustRepaint := False;
  fIgnoreEvents := False;
  StartOperation(fDefaultState, nil);
  if (fDefaultState = TCADIdleState) and Assigned(fOnIdle)
    then
    fOnIdle(Self);
end;

procedure TCADPrg.ViewOnPaint(Sender: TObject);
begin
  if fShowCursorCross then
    HideCursorCross;
  if Assigned(CurrentState) then
    SendEvent(cePaint, cmbNone, [], 0);
  if Assigned(fOldOnPaint) then
    fOldOnPaint(Sender);
  if fShowCursorCross then
    DrawCursorCross;
end;

function TCADPrg.ViewOnDblClick(Sender: TObject): Boolean;
begin
  if Assigned(CurrentState) then
    SendEvent(ceMouseDblClick, cmbNone, [], 0);
  Result := True;
end;

function TCADPrg.ViewOnKeyDown(Sender: TObject; var Key:
  Word;
  Shift: TShiftState): Boolean;
var
  MouseButton: TCS4MouseButton;
begin
  CurrentKey := Key;
  if SSLeft in Shift then
    MouseButton := cmbLeft
  else if SSRight in Shift then
    MouseButton := cmbRight
  else if ssMiddle in Shift then
    MouseButton := cmbMiddle
  else
    MouseButton := cmbNone;
  if Assigned(CurrentState) then
    SendEvent(ceKeyDown, MouseButton, Shift, CurrentKey);
  Result := True;
end;

function TCADPrg.ViewOnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState): Boolean;
var
  MouseButton: TCS4MouseButton;
begin
  if SSLeft in Shift then
    MouseButton := cmbLeft
  else if SSRight in Shift then
    MouseButton := cmbRight
  else if ssMiddle in Shift then
    MouseButton := cmbMiddle
  else
    MouseButton := cmbNone;
  if Assigned(CurrentState) then
    SendEvent(ceKeyUp, MouseButton, Shift, Key);
  CurrentKey := 0;
  Result := True;
end;

function TCADPrg.ViewOnMouseMove(Sender: TObject; Shift:
  TShiftState; var X, Y: SmallInt): Boolean;
var
  MouseButton: TCS4MouseButton;
begin
  if SSLeft in Shift then
    MouseButton := cmbLeft
  else if SSRight in Shift then
    MouseButton := cmbRight
  else if ssMiddle in Shift then
    MouseButton := cmbMiddle
  else
    MouseButton := cmbNone;
  if fShowCursorCross then
    DrawCursorCross;
  if Assigned(CurrentState) then
    SendEvent(ceMouseMove, MouseButton, Shift, CurrentKey);
  Result := True;
end;

function TCADPrg.ViewOnMouseDown(Sender: TObject; Button:
  TMouseButton; Shift: TShiftState; var X, Y: SmallInt):
  Boolean;
var
  MouseButton: TCS4MouseButton;
begin
  if Button = mbLeft then
    MouseButton := cmbLeft
  else if Button = mbRight then
    MouseButton := cmbRight
  else if Button = mbMiddle then
    MouseButton := cmbMiddle
  else
    MouseButton := cmbNone;
  if Assigned(CurrentState) then
    SendEvent(ceMouseDown, MouseButton, Shift, CurrentKey);
  Result := True;
end;

function TCADPrg.ViewOnMouseUp(Sender: TObject; Button:
  TMouseButton; Shift: TShiftState; var X, Y: SmallInt):
  Boolean;
var
  MouseButton: TCS4MouseButton;
begin
  if Button = mbLeft then
    MouseButton := cmbLeft
  else if Button = mbRight then
    MouseButton := cmbRight
  else if Button = mbMiddle then
    MouseButton := cmbMiddle
  else
    MouseButton := cmbNone;
  if Assigned(CurrentState) then
    SendEvent(ceMouseUp, MouseButton, Shift, CurrentKey);
  Result := True;
end;

constructor TCADPrg.Create(AOwner: TComponent);
var
  TmpState: TCADStateClass;
begin
  inherited Create(AOwner);
  fCursorColor := clGray;
  fShowCursorCross := False;
  fLinkedViewport := nil;
  fNewWndProc := nil;
  fOldWndProc := nil;
  fDefaultState := TCADIdleState;
  fCurrentState := fDefaultState.Create(Self, nil,
    TmpState);
  fIgnoreEvents := False;
  fRefreshAfterOp := True;
end;

destructor TCADPrg.Destroy;
begin
  if Assigned(fCurrentState) then
  begin
    fCurrentState.OnStop;
    fCurrentState.Free;
  end;
  if fIsSuspended then
  begin
    fSuspendedState.OnStop;
    fSuspendedState.Free;
  end;
  fCurrentState := nil;
  LinkedViewport := nil;
  inherited Destroy;
end;

procedure TCADPrg.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = LinkedViewport) and (Operation = opRemove)
    then
    LinkedViewport := nil;
end;

procedure TCADPrg.SubclassedWinProc(var Msg: TMessage);
var
  LastSet, Propagate: Boolean;
begin
  Propagate := True;
  if not (csDesigning in ComponentState) then
    case Msg.Msg of
      WM_MOUSEMOVE:
        with TWMMouseMove(Msg) do
          Propagate := ViewOnMouseMove(LinkedViewport,
            KeysToShiftState(Keys), XPos, YPos);
      CM_INVALIDATE:
        begin
          Msg.Result := CallWindowProc(fOldWndProc,
            fLinkedViewport.Handle, Msg.Msg, Msg.WParam,
            Msg.LParam);
          ViewOnPaint(Self);
          Propagate := False;
        end;
      WM_LBUTTONDOWN:
        with TWMMouse(Msg) do
          Propagate := ViewOnMouseDown(LinkedViewport,
            mbLeft,
            KeysToShiftState(Keys), XPos, YPos);
      WM_RBUTTONDOWN:
        with TWMMouse(Msg) do
          Propagate := ViewOnMouseDown(LinkedViewport,
            mbRight,
            KeysToShiftState(Keys), XPos, YPos);
      WM_LBUTTONUP:
        with TWMMouse(Msg) do
          Propagate := ViewOnMouseUp(LinkedViewport, mbLeft,
            KeysToShiftState(Keys), XPos, YPos);
      WM_RBUTTONUP:
        with TWMMouse(Msg) do
          Propagate := ViewOnMouseUp(LinkedViewport,
            mbRight,
            KeysToShiftState(Keys), XPos, YPos);
      WM_RBUTTONDBLCLK:
        begin
          ViewOnDblClick(LinkedViewport);
          with TWMMouse(Msg) do
            Propagate := ViewOnMouseDown(LinkedViewport,
              mbRight, KeysToShiftState(Keys), XPos, YPos);
        end;
      WM_LBUTTONDBLCLK:
        begin
          ViewOnDblClick(LinkedViewport);
          with TWMMouse(Msg) do
            Propagate := ViewOnMouseDown(LinkedViewport,
              mbLeft,
              KeysToShiftState(Keys), XPos, YPos);
        end;
      WM_KEYDOWN:
        with TWMKeyDown(Msg) do
          Propagate := ViewOnKeyDown(LinkedViewport,
            CharCode,
            KeyDataToShiftState(KeyData));
      WM_KEYUP:
        with TWMKeyUp(Msg) do
          Propagate := ViewOnKeyUp(LinkedViewport, CharCode,
            KeyDataToShiftState(KeyData));
    end;
  LastSet := fLinkedViewport.DisableMouseEvents;
  try
    fLinkedViewport.DisableMouseEvents := not Propagate;
    Msg.Result := CallWindowProc(fOldWndProc,
      fLinkedViewport.Handle, Msg.Msg, Msg.WParam,
      Msg.LParam);
  finally
    fLinkedViewport.DisableMouseEvents := LastSet;
  end;
end;

function TCADPrg.StartOperation(const StartState:
  TCADStateClass; Param: TCADPrgParam): Boolean;
var
  NewNext: TCADStateClass;
  TmpBool: Boolean;
begin
  Result := False;
  if not Assigned(fLinkedViewport) then
    Exit;
  if fLinkedViewport.InRepainting then
    fLinkedViewport.WaitForRepaintEnd;
  if fIsSuspended then
    Exit;
  if fIsBusy then
    StopOperation;
  fIsBusy := (StartState <> fDefaultState);
  NewNext := StartState;
  fCurrentOperation := StartState;
  if Assigned(fOnStart) then
    fOnStart(Self, fCurrentOperation, Param);
  TmpBool := True;
  repeat
    if (StartState <> fDefaultState) and (NewNext =
      fDefaultState) then
    begin
      if Assigned(fOnEndOperation) then
        fOnEndOperation(Self, fCurrentOperation,
          fCurrentState.fParam);
      GoToDefaultState(nil, nil);
      Break;
    end;
    fCurrentState.Free;
    fCurrentState := nil;
    try
      fCurrentState := NewNext.Create(Self, Param, NewNext);
      if fCurrentState.ClassType = StartState then
        TmpBool := fCurrentState.CanBeSuspended;
          // e' il primo stato a det. la sospendibilitÓ
      fCurrentState.CanBeSuspended := TmpBool;
    except
      Reset;
      Break;
    end;
    Param := fCurrentState.fParam;
    if Assigned(fOnEntState) then
      fOnEntState(Self, fCurrentState);
  until not Assigned(NewNext);
  Result := True;
end;

procedure TCADPrg.StopOperation;
begin
  if not fIsBusy or (fCurrentState = nil) then
    Exit;
  fCurrentState.OnStop;
  GoToDefaultState(fCurrentState.ClassType,
    fCurrentState.Param);
  if Assigned(fOnStop) then
    fOnStop(Self, fCurrentOperation, nil);
end;

procedure TCADPrg.Reset;
begin
  if Assigned(fCurrentState) then
  begin
    fIgnoreEvents := False;
    fCurrentState.OnStop;
    GoToDefaultState(fCurrentState.ClassType,
      fCurrentState.Param)
  end
  else
    GoToDefaultState(nil, nil)
end;

function TCADPrg.SuspendOperation(const StartState:
  TCADStateClass; Param: TCADPrgParam): Boolean;
var
  NewNext: TCADStateClass;
  TmpBool: Boolean;
begin
  Result := False;
  if fIsSuspended then
    Exit;
  if not CurrentState.CanBeSuspended then
    Exit;
  CurrentState.OnSuspend(StartState, Param);
  if not fIsBusy then
  begin
    StartOperation(StartState, Param);
    Exit;
  end;
  if fLinkedViewport.InRepainting then
    fLinkedViewport.WaitForRepaintEnd;
  fSuspendedState := CurrentState;
  fSuspendedOperation := fCurrentOperation;
  fIsSuspended := True;
  if not Assigned(Param) then
    Param := fSuspendedState.fParam;
  NewNext := StartState;
  TmpBool := True;
  repeat
    if (StartState <> fDefaultState) and (NewNext =
      fDefaultState) then
    begin
      GoToDefaultState(StartState, Param);
      Break;
    end;
    if fCurrentState <> fSuspendedState then
      fCurrentState.Free;
    fCurrentState := nil;
    try
      fCurrentState := NewNext.Create(Self, Param, NewNext);
      if fCurrentState.ClassType = StartState then
        TmpBool := fCurrentState.CanBeSuspended;
          // e' il primo stato a det. la sospendibilitÓ
      fCurrentState.CanBeSuspended := TmpBool;
    except
      Reset;
      Break;
    end;
    Param := fCurrentState.fParam;
    if Assigned(fOnEntState) then
      fOnEntState(Self, fCurrentState);
  until not Assigned(NewNext);
  Result := True;
end;

procedure TCADPrg.SendUserEvent(const Code: Word);
begin
  if not Assigned(fLinkedViewport) then Exit;
  try
    SendEvent(ceUserDefined, cmbNone, [], Code);
  except
    Reset;
  end;
end;

procedure TCADPrg.SendCADEvent(Event: TCADPrgEvent;
  MouseButton:
  TMouseButton; Shift: TShiftState; Key: Word);
var
  Button: TCS4MouseButton;
begin
  if MouseButton = mbLeft then
    Button := cmbLeft
  else if MouseButton = mbRight then
    Button := cmbRight
  else if MouseButton = mbMiddle then
    Button := cmbMiddle
  else
    Button := cmbNone;
  if not Assigned(fLinkedViewport) then Exit;
  try
    SendEvent(Event, Button, Shift, Key);
  except
    Reset;
  end;
end;

procedure TCADPrg.RepaintAfterOperation;
begin
  fMustRepaint := True;
  fRepaintRect := Rect2D(0.0, 0.0, 0.0, 0.0);
end;

procedure TCADPrg.RepaintRectAfterOperation(const ARect:
  TRect2D);
begin
  fMustRepaint := True;
  fRepaintRect := ARect;
end;

procedure TCADPrg.SetShowCursorCross(B: Boolean);
begin
  if fShowCursorCross <> B then
  begin
    fShowCursorCross := B;
    if not B then
      HideCursorCross;
  end;
end;

procedure TCADPrg.SetCursorColor(C: TColor);
begin
  if C = fCursorColor then
    Exit;
  if fShowCursorCross then
    DrawCursorCross;
  fCursorColor := C;
  if fShowCursorCross then
    DrawCursorCross;
end;

// =====================================================================
// TCADPrg2D
// =====================================================================

function TCADPrg2D.GetVPPoint: TPoint2D;
begin
  Result := fCurrentViewportPoint;
end;

procedure TCADPrg2D.SetVPPoint(const PT: TPoint2D);
begin
  fCurrentViewportPoint := CartesianPoint2D(PT);
end;

function TCADPrg2D.GetVPSnappedPoint: TPoint2D;
begin
  Result := GetVPPoint;
  if not UseSnap then
    Exit;
  with Result do
  begin
    if XSnap <> 0 then
      Result.X := Round(X / XSnap) * XSnap;
    if YSnap <> 0 then
      Result.Y := Round(Y / YSnap) * YSnap;
    Result.W := 1.0;
  end;
  if Assigned(fSnapFilter) then
    fSnapFilter(Self, CurrentState, fSnapOriginPoint,
      Result);
end;

function TCADPrg2D.ViewOnMouseMove(Sender: TObject; Shift:
  TShiftState; var X, Y: SmallInt): Boolean;
begin
  fCurrentViewportPoint :=
    Viewport2D.ScreenToViewport(Point2D(X, Y));
  if Assigned(fMouseMoveFilter) then
  begin
    fMouseMoveFilter(Self, CurrentState,
      fCurrentViewportPoint,
      X, Y);
    if Assigned(Viewport2D.OnMouseMove2D) then
      // if there will be a friend directive like in C++, it will be better
      // to call the MouseMove handler directly :)
      Viewport2D.OnMouseMove2D(Sender, Shift,
        fCurrentViewportPoint.X, fCurrentViewportPoint.Y, X,
        Y);
    inherited ViewOnMouseMove(Sender, Shift, X, Y);
    Result := False;
  end
  else
    Result := inherited ViewOnMouseMove(Sender, Shift, X,
      Y);
end;

function TCADPrg2D.ViewOnMouseDown(Sender: TObject; Button:
  TMouseButton; Shift: TShiftState; var X, Y: SmallInt):
  Boolean;
begin
  fCurrentViewportPoint :=
    Viewport2D.ScreenToViewport(Point2D(X, Y));
  if Assigned(fMouseButtonFilter) then
  begin
    fMouseButtonFilter(Self, CurrentState, Button,
      fCurrentViewportPoint, X, Y);
    if Assigned(Viewport2D.OnMouseDown2D) then
      // if there will be a friend directive like in C++, it will be better
      // to call the MouseMove handler directly :)
      Viewport2D.OnMouseDown2D(Sender, Button, Shift,
        fCurrentViewportPoint.X, fCurrentViewportPoint.Y, X,
        Y);
    inherited ViewOnMouseDown(Sender, Button, Shift, X, Y);
    Result := False;
  end
  else
    Result := inherited ViewOnMouseDown(Sender, Button,
      Shift,
      X, Y);
end;

function TCADPrg2D.ViewOnMouseUp(Sender: TObject; Button:
  TMouseButton; Shift: TShiftState; var X, Y: SmallInt):
  Boolean;
begin
  fCurrentViewportPoint :=
    Viewport2D.ScreenToViewport(Point2D(X, Y));
  if Assigned(fMouseButtonFilter) then
  begin
    fMouseButtonFilter(Self, CurrentState, Button,
      fCurrentViewportPoint, X, Y);
    if Assigned(Viewport2D.OnMouseUp2D) then
      // if there will be a friend directive like in C++, it will be better
      // to call the MouseMove handler directly :)
      Viewport2D.OnMouseUp2D(Sender, Button, Shift,
        fCurrentViewportPoint.X, fCurrentViewportPoint.Y, X,
        Y);
    inherited ViewOnMouseUp(Sender, Button, Shift, X, Y);
    Result := False;
  end
  else
    Result := inherited ViewOnMouseUp(Sender, Button, Shift,
      X,
      Y);
end;

function TCADPrg2D.GetViewport2D: TCADViewport2D;
begin
  Result := LinkedViewport as TCADViewport2D;
end;

procedure TCADPrg2D.SetViewport2D(View2D: TCADViewport2D);
begin
  LinkedViewport := View2D;
end;

constructor TCADPrg2D.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  XSnap := 10.0;
  YSnap := 10.0;
  fLastCursorPos := Point2D(0.0, 0.0);
  fSnapOriginPoint := Point2D(MaxCoord, MaxCoord);
end;

destructor TCADPrg2D.Destroy;
begin
  SetViewport2D(nil);
  inherited Destroy;
end;

procedure _DrawCursorCross2D(const Viewp: TCADViewport2D;
  const
  PT: TPoint2D);
var
  ScrPt: TPoint;
begin
  with Viewp do
  begin
    ScrPt := Point2DToPoint(ViewportToScreen(PT));
    Canvas.MoveTo(ScrPt.X, ClientRect.Top);
    Canvas.LineTo(ScrPt.X, ClientRect.Bottom);
    Canvas.MoveTo(ClientRect.Left, ScrPt.Y);
    Canvas.LineTo(ClientRect.Right, ScrPt.Y);
  end;
end;

procedure TCADPrg2D.DrawCursorCross;
begin
  if (not Assigned(Viewport)) or (Viewport.HandleAllocated =
    False) or (Viewport.InRepainting) then
    Exit;
  with Viewport2D do
  try
    Canvas.Pen.Mode := pmXOr;
    Canvas.Pen.Color := CursorColor xor BackGroundColor;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := 1;
    _DrawCursorCross2D(Viewport2D, fLastCursorPos);
    fLastCursorPos := CurrentViewportSnappedPoint;
    _DrawCursorCross2D(Viewport2D, fLastCursorPos);
  except
  end;
end;

procedure TCADPrg2D.HideCursorCross;
begin
  if (not Assigned(Viewport)) or (Viewport.HandleAllocated =
    False) or (Viewport.InRepainting) then
    Exit;
  with Viewport2D do
  try
    Canvas.Pen.Mode := pmXOr;
    Canvas.Pen.Color := CursorColor xor BackGroundColor;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := 1;
    _DrawCursorCross2D(Viewport2D, fLastCursorPos);
  except
  end;
end;

initialization
  //MD5Stream_try('qq');
  CADSysInitClassRegister;

  CADSysRegisterClass(0, TContainer2D);
  CADSysRegisterClass(1, TSourceBlock2D);
  CADSysRegisterClass(2, TBlock2D);

  CADSysRegisterClass(3, TLine2D);
  CADSysRegisterClass(4, TPolyline2D);
  CADSysRegisterClass(5, TPolygon2D);
  CADSysRegisterClass(6, TRectangle2D);
  CADSysRegisterClass(7, TArc2D);
  CADSysRegisterClass(8, TEllipse2D);
  CADSysRegisterClass(9, TText2D);
  CADSysRegisterClass(10, TBitmap2D);
  CADSysRegisterClass(12, TJustifiedVectText2D);
  CADSysRegisterClass(13, TCircle2D);
  CADSysRegisterClass(14, TStar2D);
  CADSysRegisterClass(15, TSector2D);
  CADSysRegisterClass(16, TSegment2D);
  CADSysRegisterClass(20, TSmoothPath2D);
  CADSysRegisterClass(21, TClosedSmoothPath2D);
  CADSysRegisterClass(22, TBezierPath2D);
  CADSysRegisterClass(23, TClosedBezierPath2D);
  CADSysRegisterClass(24, TSymbol2D);
finalization
end.

